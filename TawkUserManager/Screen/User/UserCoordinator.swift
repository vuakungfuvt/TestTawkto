//
//  HomeCoordinator.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit
import Combine

class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var userViewModel: UserViewModel?
    private var cancelBag = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        let userViewController = UserViewController()
        let userViewModel = UserViewModel()
        self.userViewModel = userViewModel
        userViewModel.onNext.sink(receiveValue: { [weak self] userModel in
            self?.goToUserDetail(userModel: userModel)
        }).store(in: &cancelBag)
        userViewController.configViewModel(viewModel: userViewModel)
        navigationController.pushViewController(userViewController, animated: false)
    }
    
    func goToUserDetail(userModel: UserModel) {
        let userDetailViewController = UserDetailViewController()
        let userDetailViewModel = UserDetailViewModel(userModel: userModel)
        userDetailViewModel.onBack.sink(receiveValue: { [weak self] userModel in
            self?.navigationController.popViewController(animated: true)
            _ = self?.userViewModel?.onUpdate.send(userModel)
        }).store(in: &cancelBag)
        userDetailViewController.configViewModel(viewModel: userDetailViewModel)
        navigationController.pushViewController(userDetailViewController, animated: true)
    }
}
