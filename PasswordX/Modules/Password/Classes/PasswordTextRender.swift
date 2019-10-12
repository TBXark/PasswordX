//
//  PasswordTextRender.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit
import PasswordCryptor

struct PasswordTextRender {

    static func render(font: UIFont, password: String) -> NSAttributedString {
        let main = NSMutableAttributedString()
        for c in password {
            let type = PasswordCharacterType.build(c)
            let string =  String(c)
            var attributes: [NSAttributedString.Key: Any] = [.font: font]
            switch type {
            case .none, .symbols:
                attributes[.foregroundColor] = UIColor(red: 0.89, green: 0.26, blue: 0.20, alpha: 1.00)
            case .lowercaseLetters, .uppercaseLetters:
                attributes[.foregroundColor] = UIColor.darkGray
            case .digits:
                attributes[.foregroundColor] = UIColor(red: 0.11, green: 0.55, blue: 1.00, alpha: 1.00)
            }
            main.append(NSAttributedString(string: string, attributes: attributes))
        }
        return main
    }
}
