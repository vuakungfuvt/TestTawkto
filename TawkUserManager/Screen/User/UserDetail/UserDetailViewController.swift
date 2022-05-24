//  UserDetailViewController.swift
//  UserDetail
//
//  Created by Nithi Kulasiriswatdi on 10/5/2564 BE.
//

import UIKit
import Combine

class UserDetailViewController: UIViewController {
    @IBOutlet private weak var nameHeaderLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headerImageView: DownloadImageView!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var companyLabel: UILabel!
    @IBOutlet private weak var blogLabel: UILabel!
    @IBOutlet private weak var noteTextView: UITextView!
    @IBOutlet private weak var bottomScrollViewCtr: NSLayoutConstraint!
    private var display = UserDetailDisplayModel()
    
    private var viewModel: UserDetailViewModel!
    private var cancelBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.onLoading.send(())
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomScrollViewCtr.constant = keyboardSize.height
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
            }
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.view.layoutIfNeeded()
                self.scrollView.scrollToBottom()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardHide(notification: NSNotification) {
        bottomScrollViewCtr.constant = 0
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction private func saveAction(_ sender: Any) {
        guard var userModel = display.userModel else {
            return
        }
        userModel.note = noteTextView.text
        self.display.userModel = userModel
        viewModel.onSaveNote.send(userModel)
    }
    
    @IBAction private func backAction(_ sender: Any) {
        guard let userModel = display.userModel else {
            return
        }
        viewModel.onBack.send(userModel)
    }
}
extension UserDetailViewController: ControllerType {

    typealias ViewModelType = UserDetailViewModel
    
    func configViewModel(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        infoStackView.layer.borderWidth = 1
        infoStackView.layer.borderColor = UIColor.black.cgColor
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.black.cgColor
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(notification:)),
                                               name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(notification:)),
                                               name: UIWindow.keyboardWillHideNotification, object: nil)
        setupToolbar()
    }
    
    func bindViewModel() {
        viewModel.display.receive(on: RunLoop.main).sink(receiveValue: { [weak self] display in
            self?.setupDisplay(display: display)
        }).store(in: &cancelBag)
        viewModel.savedNote.receive(on: RunLoop.main).sink(receiveValue: { [weak self] isSuccess in
            self?.noteTextView.resignFirstResponder()
            let alertController = UIAlertController(
                title: isSuccess ? "Success!" : "Fail!",
                message: isSuccess ? "Save note success" : "Save note fail",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            
            self?.present(alertController, animated: true)
        }).store(in: &cancelBag)
    }
    
    func setupDisplay(display: UserDetailDisplayModel) {
        self.display = display
        nameHeaderLabel.text = display.userModel?.name
        headerImageView.setImage(with: display.userModel?.avatarUrl ?? "")
        followersLabel.text = "followers: \(display.userModel?.followers ?? 0)"
        followingLabel.text = "following: \(display.userModel?.following ?? 0)"
        nameLabel.text = "name: \(display.userModel?.name ?? "")"
        companyLabel.text = "company: \(display.userModel?.company ?? "")"
        blogLabel.text = "blog: \(display.userModel?.blog ?? "")"
        noteTextView.text = display.userModel?.note
    }
    
    private func setupToolbar() {
        let toolBar = UIToolbar()
        toolBar.tintColor = .black
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        noteTextView.inputAccessoryView = toolBar
        noteTextView.tintColor = .clear
    }
    
    @objc private func doneAction() {
        noteTextView.resignFirstResponder()
    }
}

extension UserDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard offsetY <= 0 else {
            let alpha = CGFloat((100 - offsetY) / 100)
            nameHeaderLabel.alpha = alpha < 0 ? 0 : alpha
            return
        }
        nameHeaderLabel.alpha = 1
        var transform = CATransform3DTranslate(CATransform3DIdentity, 0, offsetY, 0)
        let scaleFactor = 1 + (-1 * offsetY / (UIScreen.main.bounds.width / 2))
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
        headerImageView.layer.transform = transform
    }
}
