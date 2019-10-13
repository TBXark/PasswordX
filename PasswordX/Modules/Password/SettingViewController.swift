//
//  SettingViewController.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit
import SafariServices
import PasswordCryptor

class SettingViewController: UIViewController {

    enum Section: CaseIterable {

        case length
        case characterType
        case style
        case cryptorType
        case saveMasterKey
        case saveConfig
        case restoreConfig
        case about

        var count: Int {
            switch self {
            case .characterType:
                return PasswordCharacterType.allCases.count
            case .style:
                return 1 + PasswordStyle.Separator.allCases.count
            case .cryptorType:
                return PasswordCryptorType.allCases.count
            case .length:
                return 1
            case .saveMasterKey:
                return 2
            case .saveConfig:
                return 1
            case .restoreConfig:
                return 1
            case .about:
                return 1
            }
        }

    }

    private let dataSource: [Section] = {
        if BiometricAuth.isBiometricAuthenticationAvailable() {
            return [Section.length, Section.characterType, Section.style, Section.cryptorType, Section.saveMasterKey, Section.saveConfig, Section.restoreConfig, Section.about]
        } else {
            return [Section.length, Section.characterType, Section.style, Section.cryptorType, Section.saveConfig, Section.restoreConfig, Section.about]
        }
    }()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private var config = PasswordConfigService.shared.configValue

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
        bindTargetAction()

    }

    private func layoutViewController() {
        self.title = "Setting"

        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "slider")
        tableView.rowHeight = 60
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(view)
        }

        navigationItem.leftBarButtonItem = QuickBarButton.build(title: "Close", action: {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })

        navigationItem.rightBarButtonItem = QuickBarButton.build(title: "Save", action: {[weak self] _ in
            guard let self = self else {
                return
            }
            self.dismiss(animated: true, completion: nil)
            try? PasswordConfigService.shared.update(config: self.config)
        })
    }

    private func  bindTargetAction() {

    }

}

extension SettingViewController: UITableViewDelegate {

    private func reloadSaveMasterKeySection(section: Int, newValue: Bool) {
        PasswordConfigService.shared.canSaveMasterKey = newValue
        tableView.reloadSections(IndexSet(integer: section), with: .none)

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource[indexPath.section] {
        case .characterType:
            let type = PasswordCharacterType.allCases[indexPath.row]
            if config.characterType.contains(type) {
                if config.characterType.count == 1 {
                    UIAlertController.show(title: "Warning", message: "Choose at least one character set", in: self)
                    return
                }
                config.characterType.remove(type)
            } else {
                config.characterType.insert(type)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        case .style:
            guard let type = PasswordStyle(index: indexPath.row, length: config.style.parttenLength) else {
                return
            }
            config.style = type
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        case .cryptorType:
            config.cryptorType = PasswordCryptorType.allCases[indexPath.row]
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        case .length:
            break
        case .saveMasterKey:
            if indexPath.row == 0, !PasswordConfigService.shared.canSaveMasterKey {
                BiometricAuth.auth(localizedReason: "SaveMasterKey") {[weak self] (isSuccess, error) in
                    guard let self = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        if isSuccess {
                            self.reloadSaveMasterKeySection(section: indexPath.section, newValue: true)
                        } else {
                            let reason = error?.localizedDescription ?? "Unknow reason"
                            UIAlertController.show(title: "Error", message: reason, in: self)
                        }
                    }
                }

            } else {
                PasswordConfigService.shared.canSaveMasterKey = indexPath.row == 0
                try? PasswordConfigService.shared.update(config: PasswordConfigService.shared.configValue)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
        case .saveConfig:
            if config != PasswordConfigService.shared.configValue {
                let alert = UIAlertController(title: "Warning", message: "The current configuration is different from the saved configuration. If you save it, export the configuration.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak self] _ in
                    guard let self = self else {
                        return
                    }
                    try? PasswordConfigService.shared.update(config: self.config)
                    self.tableView(tableView, didSelectRowAt: indexPath)
                }))
                alert.addAction(UIAlertAction.init(title: "Don't Save", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                let json = (try? JSONEncoder().encode(config))?.base64EncodedString() ?? ""
                UIPasteboard.general.string = json
                UIAlertController.show(title: "Success", message: "The configuration information has been saved on the clipboard, please keep it in a safe place.", in: self)
            }
        case .restoreConfig:
            if let text = UIPasteboard.general.string,
                let data = Data(base64Encoded: text),
                let config = try? JSONDecoder().decode(PasswordConfig.self, from: data) {
                let alert = UIAlertController(title: "Warning", message: "Replace the current configuration with the configuration in the clipboard?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Replace", style: .destructive, handler: {[weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.config = config
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                UIAlertController.show(title: "Alert", message: "Failed to get configuration information from clipboard.", in: self)
            }
        case .about:
            present(SFSafariViewController(url: URL(string: "https://github.com/TBXark/PasswordX")!), animated: true, completion: nil)
        }

    }
}

extension SettingViewController: UITableViewDataSource {

    private func dequeueTextCell(tableView: UITableView, indexPath: IndexPath, title: String, subtitle: String, isSelected: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "text") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "text")
        cell.selectionStyle = .none
        cell.textLabel?.attributedText = NSAttributedString(text: title,
                                                            color: UIColor.darkGray,
                                                            font: UIFont.boldSystemFont(ofSize: 14))
        cell.detailTextLabel?.attributedText = NSAttributedString(text: subtitle,
                                                                  color: UIColor.lightGray,
                                                                  font: UIFont.systemFont(ofSize: 10))
        cell.accessoryType = isSelected ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch dataSource[section] {
        case .characterType:
            return "Character Type"
        case .style:
            return "Style"
        case .cryptorType:
            return "Cryptor Type"
        case .length:
            return "Password length"
        case .saveMasterKey:
            return "Auto Save MasterKey"
        case .saveConfig:
            return "Save Config"
        case .restoreConfig:
            return "Restore Config"
        case .about:
            return "About"
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource[section]
        switch  section {
        case .style:
            switch config.style {
            case .character:
                return section.count
            default:
                return section.count + 1
            }
        default:
            return section.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource[indexPath.section] {
        case .characterType:
            let type = PasswordCharacterType.allCases[indexPath.row]
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: type.title,
                                   subtitle: String(type.characterarList),
                                   isSelected: config.characterType.contains(type))
        case .style:
            if let style = PasswordStyle(index: indexPath.row, length: config.style.parttenLength) {
                return dequeueTextCell(tableView: tableView,
                                       indexPath: indexPath,
                                       title: style.title,
                                       subtitle: style.example,
                                       isSelected: config.style == style)

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! SliderTableViewCell
                cell.configure(title: "Partten length:  ", min: 4, max: 10, value: config.style.parttenLength) {[weak self] newLength in
                    guard let self = self else {
                        return
                    }
                    switch self.config.style {
                    case .character:
                        break
                    case .word(let separator, length: _):
                        self.config.style = .word(separator: separator, length: newLength)
                        let idxs = (0..<indexPath.row).map({ IndexPath(row: $0, section: indexPath.section)})
                        self.tableView.reloadRows(at: idxs, with: .none)
                    }
                }
                return cell
            }
        case .cryptorType:
            let type = PasswordCryptorType.allCases[indexPath.row]
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: type.rawValue,
                                   subtitle: "",
                                   isSelected: config.cryptorType == type)
        case .length:
            let cell = tableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! SliderTableViewCell
            cell.configure(title: "Password length:  ", min: 1, max: 30, value: config.length) {[weak self] newLength in
                guard let self = self else {
                    return
                }
                self.config.length = newLength
            }
            return cell
        case .saveMasterKey:
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: indexPath.row == 0 ? "Yes" : "No",
                                   subtitle: "",
                                   isSelected: (indexPath.row == 0) == PasswordConfigService.shared.canSaveMasterKey )
        case .restoreConfig:
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: "Restore config by pasteboard",
                                   subtitle: "",
                                   isSelected: false)
        case .saveConfig:
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: "Save config to pasteboard",
                                   subtitle: "",
                                   isSelected: false)
        case .about:
            return dequeueTextCell(tableView: tableView,
                                   indexPath: indexPath,
                                   title: "About",
                                   subtitle: "https://github.com/TBXark/PasswordX",
                                   isSelected: false)
        }

    }

}

extension PasswordStyle {
    var parttenLength: Int {
        switch self {
        case .character:
            return 4
        case .word(separator: _, let length):
            return length
        }
    }

    init?(index: Int, length: Int) {
        if index == 0 {
            self = .character
        } else if (1..<(PasswordStyle.Separator.allCases.count + 1)).contains(index) {
            self = .word(separator: PasswordStyle.Separator.allCases[index - 1], length: length)
        } else {
            return nil
        }
    }

    var example: String {
        switch self {
        case .character:
            return "xxxxxxxxxx"
        case .word(let separator, let length):
            return Array<String>(repeating: Array<String>(repeating: "x", count: length).joined(), count: 3).joined(separator: separator.char)
        }
    }

    var title: String {
        switch self {
        case .character:
            return "character"
        case .word(let separator, length: _):
            return separator.rawValue
        }
    }

}
