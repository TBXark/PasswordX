//
//  TextHUG.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/11.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit

public struct TextHUG {

    public static func show(text: String, duration: TimeInterval = 1, in view: UIView) {
        let displayDuration = max(1, duration)
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.80)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.shadowColor = UIColor.black
        label.numberOfLines = 0
        label.text = text
        label.frame = view.bounds
        label.sizeToFit()
        label.frame = label.frame.insetBy(dx: -10, dy: -5)
        view.addSubview(label)
        label.center = view.center
        label.alpha = 0
        label.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 1
            label.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: displayDuration - 0.4, options: .curveLinear, animations: {
                label.alpha = 0
                label.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
            }, completion: { _ in
                label.removeFromSuperview()
            })
        })
    }
}
