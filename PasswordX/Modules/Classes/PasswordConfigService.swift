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
    
    
    private let configStore: BehaviorRelay<PasswordConfig>
    var configValue: PasswordConfig {
        return configStore.value
    }
    let configChange: Observable<PasswordConfig>
    
    private init() {
        if let json =  UserDefaults.standard.data(forKey: Config.configCacheKey),
            let model = try? JSONDecoder().decode(PasswordConfig.self, from: json) {
            let store = BehaviorRelay<PasswordConfig>(value: model)
            self.configStore = store
            self.configChange = store.asObservable().share()
        } else {
            let defaultConfig = PasswordConfig(characterType: [.digits, .lowercaseLetters, .uppercaseLetters, .symbols],
                                               style: .word(separator: .hyphen, length: 6),
                                               cryptorType: .AES256,
                                               length: 18)
            let store = BehaviorRelay<PasswordConfig>(value: defaultConfig)
            self.configStore = store
            self.configChange = store.asObservable().share()
        }
    }
    
    func update(config: PasswordConfig) throws {
        let json = try JSONEncoder().encode(config)
        UserDefaults.standard.set(json, forKey: Config.configCacheKey)
        UserDefaults.standard.synchronize()
        configStore.accept(config)
    }
    
}
