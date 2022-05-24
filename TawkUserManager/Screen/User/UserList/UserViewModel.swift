//
//  UserViewModel.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Combine
import Foundation

class UserViewModel: ViewModelType {
    private var cancelBag = Set<AnyCancellable>()
    let onUpdate = PassthroughSubject<UserModel, Never>()
    let onRequest = PassthroughSubject<Int, Never>()
    let onResponse = PassthroughSubject<([UserModel], Bool), Never>()
    let onSearchText = CurrentValueSubject<String, Never>("")
    let display = PassthroughSubject<UserDisplayModel, Never>()
    let onNext = PassthroughSubject<UserModel, Never>()
    private var userModels: [UserModel] = []
    
    init() {
        observeInput()
    }
    
    private func observeInput() {
        onRequest.sink(receiveValue: { [weak self] userId in
            self?.sendRequest(userId: userId)
        }).store(in: &cancelBag)
        onResponse.combineLatest(onSearchText.map({ $0.trim().lowercased() }))
            .sink(receiveValue: { [weak self] response, searchText in
                guard let self = self else {
                    return
                }
                if searchText.isEmpty {
                    self.display.send(UserDisplayModel(userModels: response.0, isLoadmore: response.1))
                } else {
                    let searchedUserModels = response.0.filter {
                        return $0.login.lowercased().contains(searchText)
                        || ($0.note?.lowercased().contains(searchText) ?? false)
                    }
                    self.display.send(UserDisplayModel(userModels: searchedUserModels, isLoadmore: false))
                }
            }).store(in: &cancelBag)
    }
    
    private func sendRequest(userId: Int) {
        let request = UserRequest(since: userId)
        APIService.shared.doRequestArray(
            request,
            completion: { [weak self] (result: Result<[UserModel], APIError>) in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let success):
                    let processedData = self.processData(userModels: success)
                    if userId == 0 { // first load
                        self.userModels = processedData
                        self.onResponse.send((self.userModels, false))
                    } else { // load more
                        self.userModels.append(contentsOf: processedData)
                        self.onResponse.send((self.userModels, true))
                    }
                case .failure(let error):
                    if userId == 0 && error == .noInternet {
                        let savedUsers = UserManager.shared.getAllUser()
                        let processedData = self.processData(userModels: savedUsers)
                        self.userModels = processedData
                        self.onResponse.send((self.userModels, false))
                    }
                }
            })
    }
    
    private func processData(userModels: [UserModel]) -> [UserModel] {
        var processedUserModels = userModels
        for index in processedUserModels.indices {
            let userId = processedUserModels[index]._id
            if let user = UserManager.shared.getUser(userId: userId) {
                processedUserModels[index].followers = user.followers
                processedUserModels[index].following = user.following
                processedUserModels[index].note = user.note
                processedUserModels[index].blog = user.blog
                processedUserModels[index].company = user.company
                processedUserModels[index].name = user.name
            }
        }
        return processedUserModels
    }
}
