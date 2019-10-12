//
//  ViewController.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit
import SnapKit
import PasswordCryptor


class GeneratorViewController: UIViewController {
    
    private let headerContainer = UIView()

    private let passwordTextField = UITextField()
    private let passwordCopyButton = QuickButton()
    

    
    private let identityTextField = UITextField()
    private let identityHistoryButton = QuickButton()
    private let masterKeyTextField = UITextField()
    private let masterHiddenButton = QuickButton()

    private let settingButton = QuickButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        bindTargetAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PasswordConfigService.shared.reloadConfig()
    }
    
    
   private func layoutViewController() {
        
        let space: CGFloat = 50
                
        view.backgroundColor = UIColor.white
        
        headerContainer.backgroundColor = UIColor(red: 0.24, green: 0.31, blue: 0.45, alpha: 1.00)
        view.addSubview(headerContainer)
        
        do {
            passwordTextField.layer.cornerRadius = 8
            passwordTextField.backgroundColor = UIColor.white
            passwordTextField.textAlignment = .center
            passwordTextField.minimumFontSize = 0
            passwordTextField.adjustsFontSizeToFitWidth = true
            passwordTextField.placeholder = "PasswordX"
            passwordTextField.isUserInteractionEnabled = false
            headerContainer.addSubview(passwordTextField)
            
            
            passwordCopyButton.setTitle("Copy Secure Password", for: .normal)
            passwordCopyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            passwordCopyButton.setTitleColor(UIColor.white, for: .normal)
            passwordCopyButton.backgroundColor = UIColor(red: 0.32, green: 0.70, blue: 0.28, alpha: 1.00)
            passwordCopyButton.layer.cornerRadius = 25
            headerContainer.addSubview(passwordCopyButton)
                
            let label = UILabel()
            label.text = "PasswordX, Offline password manager."
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 30)
            label.numberOfLines = 0
            label.textColor = UIColor.white
            headerContainer.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.right.equalTo(headerContainer)
                make.top.equalTo(view).offset(space * 2)
                make.height.equalTo(label)
            }
            
            passwordCopyButton.snp.makeConstraints { (make) in
                make.width.equalTo(260)
                make.height.equalTo(50)
                make.top.equalTo(passwordTextField.snp.bottom).offset(space)
                make.bottom.equalTo(headerContainer).offset(-space)
                make.centerX.equalTo(headerContainer)
            }
            
            passwordTextField.snp.makeConstraints { (make) in
                make.left.equalTo(headerContainer).offset(space)
                make.right.equalTo(headerContainer).offset(-space)
                make.top.equalTo(label.snp.bottom).offset(space)
                make.height.equalTo(54)
            }
            
            headerContainer.snp.makeConstraints { (make) in
                make.top.centerX.equalTo(view)
                make.width.equalTo(view)
                make.height.equalTo(headerContainer)
                
            }

        }
                
        do {
            
            func containerBuilder(rect: CGRect, content: UIView?) -> UIView {
                let container = UIView(frame: rect)
                content?.frame = rect
                if let c = content {
                    container.addSubview(c)
                }
                return container
            }
            
            let tfViewRect = CGRect(x: 0, y: 0, width: 54, height: 54)
            
            identityHistoryButton.setImage(UIImage(named: "history"), for: .normal)
            identityTextField.rightView = containerBuilder(rect: tfViewRect, content: identityHistoryButton)
            identityTextField.rightViewMode = .always
            identityTextField.leftView = containerBuilder(rect: tfViewRect, content: nil)
            identityTextField.leftViewMode = .always
            identityTextField.placeholder = "Password identity"
            
            
            masterKeyTextField.placeholder = "Master key"
            masterKeyTextField.isSecureTextEntry = true
            masterKeyTextField.keyboardType = .asciiCapable
            masterKeyTextField.text = PasswordConfigService.shared.canSaveMasterKey ? PasswordConfigService.shared.masterKey : nil

            masterHiddenButton.setImage(UIImage(named: "visibility_on"), for: .normal)
            masterHiddenButton.setImage(UIImage(named: "visibility_off"), for: .selected)
            masterHiddenButton.isSelected = true
            masterHiddenButton.frame = tfViewRect
            
            masterKeyTextField.rightView = containerBuilder(rect: tfViewRect, content: masterHiddenButton)
            masterKeyTextField.rightViewMode = .always
            masterKeyTextField.leftView = containerBuilder(rect: tfViewRect, content: nil)
            masterKeyTextField.leftViewMode = .always


            for tf in [identityTextField, masterKeyTextField] {
                tf.layer.cornerRadius = 8
                tf.backgroundColor = UIColor(white: 0.9, alpha: 1)
                tf.textAlignment = .center
                tf.font = UIFont.boldSystemFont(ofSize: 16)
                tf.textColor = UIColor.darkGray
                tf.textContentType = .none
                
                view.addSubview(tf)
                
                let label = UILabel()
                label.text = tf.placeholder
                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = UIColor.darkGray
                view.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.left.right.equalTo(tf)
                    make.bottom.equalTo(tf.snp.top)
                    make.height.equalTo(30)
                }
            }


            identityTextField.snp.makeConstraints { (make) in
                make.left.right.equalTo(passwordTextField)
                make.top.equalTo(headerContainer.snp.bottom).offset(space)
                make.height.equalTo(54)
            }
            
            masterKeyTextField.snp.makeConstraints { (make) in
               make.left.right.equalTo(passwordTextField)
               make.top.equalTo(identityTextField.snp.bottom).offset(space)
               make.height.equalTo(54)
           }

        }
    
        do {
            let settingContainer = UIView()
            view.addSubview(settingContainer)
            settingContainer.snp.makeConstraints { (make) in
                make.bottom.equalTo(view)
                make.top.equalTo(masterKeyTextField.snp.bottom)
                make.left.right.equalTo(view)
            }
            
            settingButton.setImage(UIImage(named: "setting"), for: .normal)
            view.addSubview(settingButton)
            
            settingButton.snp.makeConstraints { (make) in
                make.size.equalTo(80)
                make.center.equalTo(settingContainer)
            }
            
        }
    
    }
       
    
    private func bindTargetAction() {
        
        masterKeyTextField.addTarget(self, action: #selector(GeneratorViewController.updatePassword), for: [.allEditingEvents, .valueChanged])
        identityTextField.addTarget(self, action: #selector(GeneratorViewController.updatePassword), for: [.allEditingEvents, .valueChanged])
        
        PasswordConfigService.shared.addObserver {[weak self] _ in
            self?.updatePassword(nil)
        }

        passwordCopyButton.clickAction = {[weak self] _ in
            guard let self = self else {
                return
            }
            if self.identityTextField.text?.isEmpty ?? true {
                UIAlertController.show(title: "Warning", message: "Please enter identity value.", closeTitle: "OK", closeHandler: {[weak self] _ in
                    self?.identityTextField.becomeFirstResponder()
                }, in: self)
            } else if self.masterKeyTextField.text?.isEmpty ?? true {
                UIAlertController.show(title: "Warning", message: "Please enter master key.", closeTitle: "OK", closeHandler:  {[weak self] _ in
                    self?.masterKeyTextField.becomeFirstResponder()
                }, in: self)
            } else {
                UIPasteboard.general.string = self.passwordTextField.text ?? ""
                if let id = self.identityTextField.text {
                    PasswordConfigService.shared.addIdentity(id: id)
                }
                TextHUG.show(text: "Copied!", in: self.headerContainer)
            }
        }
        
        masterHiddenButton.clickAction = {[weak self] _ in
            guard let self = self else {
                 return
             }
             self.masterHiddenButton.isSelected.toggle()
             self.masterKeyTextField.isSecureTextEntry = self.masterHiddenButton.isSelected
        }
        
        settingButton.clickAction = {[weak self] _ in
            let nav = UINavigationController(rootViewController: SettingViewController())
            self?.present(nav, animated: true, completion: nil)
        }
        
        identityHistoryButton.clickAction = {[weak self] _ in
            guard let self = self else {
                return
            }
            let vc = HistoryViewController()
            vc.didSelectId = {[weak self] id in
                guard let self = self else {
                    return
                }
                self.identityTextField.text = id
                self.identityTextField.sendActions(for: .valueChanged)
                if !(self.masterKeyTextField.text?.isEmpty ?? true) {
                    self.passwordCopyButton.sendActions(for: .touchUpInside)
                }
            }
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
        }

    }
    
    @objc private func updatePassword(_ sender: Any?) {
        let config = PasswordConfigService.shared.configValue
        let cryptor = PasswordCryptorService.buildCryptor(type: config.cryptorType)
        let key = masterKeyTextField.text ?? ""
        let id = identityTextField.text ?? ""
        let pwd = (try? cryptor.encrypt(masterKey: key, identity: id, config: config)) ?? ""
        if PasswordConfigService.shared.canSaveMasterKey,
            key != PasswordConfigService.shared.masterKey {
            PasswordConfigService.shared.masterKey = key
        }
        passwordTextField.attributedText = PasswordTextRender.render(font: UIFont.boldSystemFont(ofSize: 18), password: pwd)
    }

}

