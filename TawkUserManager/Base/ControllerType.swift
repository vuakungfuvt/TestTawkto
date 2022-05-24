//
//  ControllerType.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import Foundation

protocol ControllerType {
    associatedtype ViewModelType
    
    func configViewModel(viewModel: ViewModelType)
    func setupViews()
    func bindViewModel()
}
