//
//  ViewController.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import PasswordCryptor


class GeneratorViewController: UIViewController {
    
    private let headerContainer = UIView()

    private let passwordTextField = UITextField()
    private let passwordCopyButton = UIButton(type: .custom)
    

    private let identityTextField = UITextField()
    private let masterKeyTextField = UITextField()
    private let masterHiddenButton = UIButton(type: .custom)

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        bindObserver()
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
            label.text = "PasswordX, Offline Strong Password Generator."
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
            
            
            identityTextField.placeholder = "Password identity"
            masterKeyTextField.placeholder = "Master key"
            masterKeyTextField.isSecureTextEntry = true
            masterKeyTextField.keyboardType = .asciiCapableNumberPad
            
            masterHiddenButton.setImage(UIImage(named: "visibility_on"), for: .normal)
            masterHiddenButton.setImage(UIImage(named: "visibility_off"), for: .selected)
            masterHiddenButton.isSelected = true
            masterHiddenButton.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
            
            let masterHiddenButtonContainer = UIView(frame: masterHiddenButton.frame)
            masterHiddenButtonContainer.addSubview(masterHiddenButton)
            
            let masterKeyTextFieldLeftSpace = UIView(frame: masterHiddenButton.frame)
            
            masterKeyTextField.rightView = masterHiddenButtonContainer
            masterKeyTextField.rightViewMode = .always
            masterKeyTextField.leftView = masterKeyTextFieldLeftSpace
            masterKeyTextField.leftViewMode = .always


            for tf in [identityTextField, masterKeyTextField] {
                tf.layer.cornerRadius = 8
                tf.backgroundColor = UIColor(white: 0.9, alpha: 1)
                tf.textAlignment = .center
                tf.font = UIFont.boldSystemFont(ofSize: 16)
                tf.textColor = UIColor.darkGray
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
            
            let settingButton = UIButton()
            settingButton.setImage(UIImage(named: "setting"), for: .normal)
            view.addSubview(settingButton)
            
            settingButton.snp.makeConstraints { (make) in
                make.size.equalTo(80)
                make.center.equalTo(settingContainer)
            }
            
        }
    
    }
    
    
    private  func bindObserver() {
        
        let masterKey = masterKeyTextField.rx.text.orEmpty.asObservable().share()
        let identity = identityTextField.rx.text.orEmpty.asObservable().share()
        let config = PasswordConfigService.shared.configChange
        
        Observable.combineLatest(masterKey, identity, config, resultSelector: { (key: $0, id: $1, config: $2) })
            .throttle(RxTimeInterval.microseconds(500), scheduler: MainScheduler.asyncInstance)
            .map { (key, id, config) -> String in
                let cryptor = PasswordCryptorService.buildCryptor(type: .AES256)
                let pwd = try? cryptor.encrypt(masterKey: key, identity: id, config: config)
                return pwd ?? ""
            }
            .map({ PasswordTextRender.render(font: UIFont.boldSystemFont(ofSize: 18), password: $0)})
            .bind(to: passwordTextField.rx.attributedText)
            .disposed(by: disposeBag)
                
        passwordCopyButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else {
                    return
                }
                UIPasteboard.general.string = self.passwordTextField.text ?? ""
                TextHUG.show(text: "Copied!", in: self.headerContainer)
            })
            .disposed(by: disposeBag)
        
        masterHiddenButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else {
                    return
                }
                self.masterHiddenButton.isSelected.toggle()
                self.masterKeyTextField.isSecureTextEntry = self.masterHiddenButton.isSelected
            })
            .disposed(by: disposeBag)
    }

}

