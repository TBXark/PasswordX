//
//  PasswordConfigService.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import PasswordCryptor

extension UserDefaults {
    static var passwordGroup: UserDefaults {
        return UserDefaults(suiteName: "group.tbxark.passwordx") ?? UserDefaults.standard
    }
}

class PasswordConfigService {
    
    static let shared = PasswordConfigService()
    
    private struct Config {
        static let configCacheKey = "cache.config"
        static let masterKeyCachekey = "master.key"
        static let identityHistoryKey = "identity.history.key"
        static let canSaveMasterKeyCachekey = "can.save.master.key"
    }
    
    
    private(set) var configValue: PasswordConfig
    
    var canSaveMasterKey: Bool {
        didSet {
            if !canSaveMasterKey {
                masterKey = nil
            }
            UserDefaults.passwordGroup.set(canSaveMasterKey, forKey: Config.canSaveMasterKeyCachekey)
        }
    }
   
    var masterKey: String? {
        didSet {
            guard canSaveMasterKey else {
                return
            }
            UserDefaults.passwordGroup.set(masterKey, forKey: Config.masterKeyCachekey)
        }
    }
    
    private(set) var identityHistory: [String] = UserDefaults.passwordGroup.stringArray(forKey: Config.identityHistoryKey) ?? [] {
        didSet {
            UserDefaults.passwordGroup.set(identityHistory, forKey: Config.identityHistoryKey)
        }
    }
    
    private var configChangeNotitfication: NSNotification.Name {
        return NSNotification.Name("PasswordConfigService.configChange")
    }
    
    
    private init() {
        let canSave = UserDefaults.passwordGroup.bool(forKey: Config.canSaveMasterKeyCachekey)
        let key = canSave ? UserDefaults.passwordGroup.string(forKey: Config.masterKeyCachekey) : nil
        self.canSaveMasterKey = canSave
        self.masterKey = key
        if let json =  UserDefaults.passwordGroup.data(forKey: Config.configCacheKey),
            let model = try? JSONDecoder().decode(PasswordConfig.self, from: json) {
            self.configValue = model
        } else {
            let defaultConfig = PasswordConfig(characterType: [.digits, .lowercaseLetters, .uppercaseLetters, .symbols],
                                               style: .word(separator: .hyphen, length: 6),
                                               cryptorType: .AES256,
                                               length: 18)
            self.configValue = defaultConfig
        }
    }
    
    func update(config: PasswordConfig) throws {
        self.configValue = config
        let json = try JSONEncoder().encode(config)
        UserDefaults.passwordGroup.set(json, forKey: Config.configCacheKey)
        UserDefaults.passwordGroup.synchronize()
        NotificationCenter.default.post(name: configChangeNotitfication, object: nil)
    }
    
        
    func addObserver(configChange: ((PasswordConfig) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: configChangeNotitfication, object: nil, queue: OperationQueue.main) {[weak self] _ in
            guard let self = self else {
                return
            }
            configChange?(self.configValue)
        }
    }
    
    func addIdentity(id: String) {
        var temp = identityHistory
        if  temp.contains(id) {
            temp.removeAll(where: { $0 == id})
        }
        temp.insert(id, at: 0)
        identityHistory = temp
    }
    
    func removeIdentity(id: String) {
        identityHistory = identityHistory.filter({ $0 != id })
    }
    
}
