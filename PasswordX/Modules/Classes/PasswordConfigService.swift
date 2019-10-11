//
//  PasswordConfigService.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import RxSwift
import RxRelay
import PasswordCryptor

class PasswordConfigService {
    
    static let shared = PasswordConfigService()
    
    private struct Config {
        static let configCacheKey = "cache.config"
        static let masterKeyCachekey = "master.key"
        static let canSaveMasterKeyCachekey = "can.save.master.key"
    }
    
    private(set) var configValue: PasswordConfig
    private var configChangeNotitfication: NSNotification.Name {
        return NSNotification.Name("PasswordConfigService.configChange")
    }
    
    
    private init() {
        if let json =  UserDefaults.standard.data(forKey: Config.configCacheKey),
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
        UserDefaults.standard.set(json, forKey: Config.configCacheKey)
        UserDefaults.standard.synchronize()
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
    
}
