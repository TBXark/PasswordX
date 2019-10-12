//
//  UIKit+Extension.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/11.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit

extension NSAttributedString {
    convenience init(text: String, color: UIColor, font: UIFont) {
        self.init(string: text, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
    }

    func toMutable() -> NSMutableAttributedString {
        return (self as? NSMutableAttributedString) ?? NSMutableAttributedString(attributedString: self)
    }

    static func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let main = NSMutableAttributedString()
        main.append(lhs)
        main.append(rhs)
        return main
    }
}

extension UIAlertController {
    @discardableResult static func show(title: String, message: String, closeTitle: String = "Close", closeHandler: ((UIAlertAction) -> Void)? = nil, in viewController: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeTitle, style: .cancel, handler: closeHandler))
        viewController.present(alert, animated: true, completion: nil)
        return alert
    }
}
