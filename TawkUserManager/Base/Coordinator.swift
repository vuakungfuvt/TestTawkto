//
//  Coordinator.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
