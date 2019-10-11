//
//  QuickButton.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/11.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit


public typealias ButtonClick = (QuickButton) -> Void
public typealias BarButtonClick = (UIBarButtonItem) -> Void

open class QuickButton: UIButton {

    public var clickAction: ButtonClick?

    public var customtTitleRect: ((CGRect) -> CGRect)? {
        didSet {
            layoutSubviews()
        }
    }

    public var customtImageRect: ((CGRect) -> CGRect)? {
        didSet {
            layoutSubviews()
        }
    }

    public convenience init() {
        self.init(action: nil)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clickAction = nil
        addTarget(self, action: #selector(QuickButton.quickButtonClick(_:)), for: .touchUpInside)
    }

    public init(action: ButtonClick?) {
        super.init(frame: CGRect.zero)
        clickAction = action
        addTarget(self, action: #selector(QuickButton.quickButtonClick(_:)), for: .touchUpInside)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clickAction = nil
        addTarget(self, action: #selector(QuickButton.quickButtonClick(_:)), for: .touchUpInside)
    }

    public class func build(title: NSAttributedString,
                            image: UIImage?,
                            action: ButtonClick?) -> QuickButton {
        let button = QuickButton(action: action)
        button.setImage(image, for: .normal)
        button.setAttributedTitle(title, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageView?.layer.magnificationFilter = CALayerContentsFilter.nearest
        return button
    }

    public class func build(image img: UIImage?,
                            action: ButtonClick?) -> QuickButton {
        let button = QuickButton(action: action)
        button.setImage(img, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageView?.layer.magnificationFilter = CALayerContentsFilter.nearest
        return button
    }

    public class func build(title str: String,
                            action: ButtonClick?) -> QuickButton {
        let button = QuickButton(action: action)
        button.setTitle(str, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }

    public func setTitle(_ str: String) {
        setTitle(str, for: .normal)
    }

    public class func build(btnTitle str: String,
                            color: UIColor = UIColor.clear,
                            textColor: UIColor = UIColor.black,
                            font: UIFont = UIFont.systemFont(ofSize: 13),
                            action: ButtonClick?) -> QuickButton {
        let button = QuickButton(action: action)
        button.setTitle(str, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = font
        button.backgroundColor = color
        button.clipsToBounds = true
        button.frame.size = CGSize(width: 60, height: 28)
        return button
    }

    @objc public func quickButtonClick(_ button: QuickButton) {
        if let action = clickAction {
            action(button)
        }
    }

    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return customtTitleRect?(contentRect) ?? super.titleRect(forContentRect: contentRect)
    }

    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return customtImageRect?(contentRect) ?? super.imageRect(forContentRect: contentRect)
    }
}


public class QuickBarButton: UIBarButtonItem {

    public var clickAction: BarButtonClick?

    public class func build(image img: UIImage?,
                            action: BarButtonClick?) -> QuickBarButton {
        let button = QuickBarButton(image: img, style: .plain, target: nil, action: nil)
        button.clickAction = action
        button.target = button
        button.action = #selector(QuickBarButton.quickButtonClick(_:))
        return button
    }

    public class func build(originImage img: UIImage?,
                            action: BarButtonClick?) -> QuickBarButton {
        let button = QuickBarButton(image: img?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), style: .plain, target: nil, action: nil)
        button.clickAction = action
        button.target = button
        button.action = #selector(QuickBarButton.quickButtonClick(_:))
        return button
    }

    public class func build(title str: String,
                            action: BarButtonClick?) -> QuickBarButton {
        let button = QuickBarButton(title: str, style: .plain, target: nil, action: nil)
        button.clickAction = action
        button.target = button
        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkText,
                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .normal)

        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightText,
                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .disabled)

        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightText,
                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .highlighted)
        button.action = #selector(QuickBarButton.quickButtonClick(_:))
        return button
    }

    public class func build(view: UIView,
                            action: BarButtonClick?) -> QuickBarButton {
        let button = QuickBarButton(customView: view)
        button.clickAction = action
        button.target = button
        button.action = #selector(QuickBarButton.quickButtonClick(_:))
        return button
    }

    @objc private func quickButtonClick(_ button: UIBarButtonItem) {
        if let action = clickAction {
            action(button)
        }
    }
}
