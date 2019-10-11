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
    private let config = PasswordConfigService.shared.configValue

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        if let id = serviceIdentifiers.first?.identifier {
            identityTextField.text = id
            identityTextField.sendActions(for: .valueChanged)
            identityTextField.sendActions(for: .editingDidEnd)

        }
    }

    @IBAction func handleCancleButtonClick(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func handleOkButtonClick(_ sender: UIBarButtonItem) {
        let passwordCredential = ASPasswordCredential(user: "",
                                                      password: passwordTextField.text ?? "")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
    
    @IBAction func handleInputValueChange(_ sender: Any) {
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
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "text") ?? UITableViewCell(style: .default, reuseIdentifier: "text")
        cell.textLabel?.attributedText = NSAttributedString(string: dataSource[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return cell
    }
}
