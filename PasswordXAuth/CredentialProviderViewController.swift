//
//  CredentialProviderViewController.swift
//  PasswordXAuth
//
//  Created by TBXark on 2019/10/11.
//  Copyright © 2019 TBXark. All rights reserved.
//

import AuthenticationServices
import PasswordCryptor

class CredentialProviderViewController: ASCredentialProviderViewController {
    

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var identityTextField: UITextField!
    @IBOutlet weak var masterKeyTextField: UITextField!
    @IBOutlet weak var historyTableView: UITableView!
    
    private let dataSource = PasswordConfigService.shared.identityHistory

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        bindTargetAction()

    }
    
    func layoutViewController() {
        overrideUserInterfaceStyle = .light
        masterKeyTextField.addTarget(self, action: #selector(CredentialProviderViewController.handleInputValueChange(_:)), for: [.allEditingEvents, .valueChanged])
        identityTextField.addTarget(self, action: #selector(CredentialProviderViewController.handleInputValueChange(_:)), for: [.allEditingEvents, .valueChanged])

    }
    
    func bindTargetAction() {
        PasswordConfigService.shared.addObserver {[weak self] config in
            self?.handleInputValueChange(nil)
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PasswordConfigService.shared.reloadConfig()
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        let host = serviceIdentifiers.compactMap { (id) -> String? in
            switch id.type {
            case .domain:
                return id.identifier
            case .URL:
                return URLComponents(string: id.identifier)?.host
            @unknown default:
                return id.identifier
            }
        }.first
        if let id = host {
            identityTextField.text = id
            identityTextField.sendActions(for: .valueChanged)
        }
    }

    @IBAction func handleCancleButtonClick(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func handleOkButtonClick(_ sender: UIBarButtonItem) {
        let passwordCredential = ASPasswordCredential(user: "",
                                                      password: passwordTextField.text ?? "")
        if let id = identityTextField.text {
            PasswordConfigService.shared.addIdentity(id: id)
        }
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
    
    @objc private func handleInputValueChange(_ sender: Any?) {
        let config = PasswordConfigService.shared.configValue
        guard let key = masterKeyTextField.text,
            let id = identityTextField.text else {
            return
        }
        let cryptor = PasswordCryptorService.buildCryptor(type: config.cryptorType)
        let pwd = (try? cryptor.encrypt(masterKey: key, identity: id, config: config)) ?? ""
        passwordTextField.attributedText = PasswordTextRender.render(font: UIFont.boldSystemFont(ofSize: 18), password: pwd)
    }
    
}


extension CredentialProviderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        identityTextField.text = dataSource[indexPath.row]
        identityTextField.sendActions(for: .valueChanged)
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "text") ?? UITableViewCell(style: .default, reuseIdentifier: "text")
        cell.selectionStyle = .none
        cell.textLabel?.attributedText = NSAttributedString(string: dataSource[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return cell
    }
}
