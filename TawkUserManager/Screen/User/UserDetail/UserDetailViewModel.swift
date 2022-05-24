//
//  UserDetailViewModel.swift
//  TawkUserManager
//
//  Created by tungphan on 15/05/2022.
//

import Foundation
import Combine

class UserDetailViewModel: ViewModelType {
    var userModel: UserModel
    private var cancelBag = Set<AnyCancellable>()
    let onLoading = PassthroughSubject<Void, Never>()
    let display: CurrentValueSubject<UserDetailDisplayModel, Never>
    let onBack = PassthroughSubject<UserModel, Never>()
    let onSaveNote = PassthroughSubject<UserModel, Never>()
    let savedNote = PassthroughSubject<Bool, Never>()
    
    init(userModel: UserModel) {
        self.userModel = userModel
        display = CurrentValueSubject<UserDetailDisplayModel, Never>(UserDetailDisplayModel(userModel: userModel))
        observeInput()
    }
    
    private func observeInput() {
        onLoading.sink(receiveValue: { [weak self] in
            guard let self = self else {
                return
            }
            self.sendRequest(userModel: self.userModel)
        }).store(in: &cancelBag)
        onSaveNote.sink(receiveValue: { [weak self] userModel in
            self?.userModel = userModel
            self?.savedNote.send(UserManager.shared.saveUser(userModel))
        }).store(in: &cancelBag)
    }
    
    private func sendRequest(userModel: UserModel) {
        let request = UserDetailRequest(userName: userModel.login)
        APIService.shared.doRequest(
            request,
            completion: { [weak self] (result: Result<UserModel, APIError>) in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let success):
                    let processedUserModel = self.processData(userModel: success)
                    self.display.send(UserDetailDisplayModel(userModel: processedUserModel))
                    UserManager.shared.saveUser(processedUserModel)
                case .failure(_):
                    break
                }
            })
    }
    
    private func processData(userModel: UserModel) -> UserModel {
        var processedUserModel = userModel
        processedUserModel.note = self.userModel.note
        return processedUserModel
    }
}
