//
//  UserNoteTableViewCell.swift
//  TawkUserManager
//
//  Created by tungphan on 14/05/2022.
//

import UIKit

class UserNoteTableViewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Color.raisinBlackVeryLight.cgColor
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    private let userImageView: DownloadImageView = {
        let imageView = DownloadImageView()
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Color.raisinBlackLight.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = Color.raisinBlack
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textColor = Color.raisinBlack
        return label
    }()
    
    private let noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "note")
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.leading.equalTo(10)
            make.bottom.equalTo(-6)
            make.trailing.equalTo(-10)
        }
        
        [userImageView, nameLabel, detailLabel, noteImageView].forEach {
            containerView.addSubview($0)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.leading.equalTo(8)
            make.height.width.equalTo(64)
        }
        userImageView.layer.cornerRadius = 32
        userImageView.layer.masksToBounds = true
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.top).offset(8)
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.trailing.equalTo(noteImageView.snp.leading).offset(-4)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        noteImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
            make.trailing.equalTo(-8)
        }
    }
}

extension UserNoteTableViewCell: UserTableViewCellProtocol {
    func setData(_ data: UserModel) {
        nameLabel.text = data.login
        detailLabel.text = data.htmlUrl
        userImageView.setImage(with: data.avatarUrl)
    }
}
