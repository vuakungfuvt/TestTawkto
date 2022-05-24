//
//  UserViewController+UITableView.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userModel = display.userModels[indexPath.row]
        viewModel.onNext.send(userModel)
    }
}

extension UserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display.userModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userModel = display.userModels[indexPath.row]
        let cellType = userModel.getCellType(at: indexPath)
        if let cell = tableView.dequeueReusableCell(cellType, for: indexPath) as? UserTableViewCellProtocol {
            cell.setData(userModel)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}
