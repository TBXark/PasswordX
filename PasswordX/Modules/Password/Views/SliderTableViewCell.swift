//
//  SliderTableViewCell.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/11.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell {
    
    let sliderView = UISlider()
    let valueLabel = UILabel()
    
    private var title: String = ""
    private var valueChanged: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shareInit()
    }

    private func shareInit() {
        valueLabel.font = UIFont.systemFont(ofSize: 12)
        valueLabel.textColor = UIColor.darkGray
        
        sliderView.addTarget(self, action: #selector(SliderTableViewCell.handleSliderValueChanged(_:)), for: .valueChanged)
        
        contentView.addSubview(sliderView)
        contentView.addSubview(valueLabel)
        
        let space: CGFloat = 16
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(space)
            make.width.equalTo(150)
            make.top.bottom.equalTo(contentView)
        }
        sliderView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(valueLabel.snp.right).offset(space)
            make.right.equalTo(contentView).offset(-space)
        }
    }
    
    func configure(title: String, min: Int, max: Int, value: Int, valueChanged:  ((Int) -> Void)?) {
        self.valueChanged = nil
        self.title = title
        sliderView.minimumValue = Float(min)
        sliderView.maximumValue = Float(max)
        sliderView.value = Float(value)
        self.valueChanged = valueChanged
        updateValueLabel()
    }
    
    
    private func updateValueLabel() {
        valueLabel.attributedText = NSAttributedString(text: title, color: UIColor.darkGray, font: UIFont.boldSystemFont(ofSize: 14)) + NSAttributedString(text: String(Int(sliderView.value)), color: UIColor.gray, font: UIFont.systemFont(ofSize: 14))
    }
    
    @objc private func  handleSliderValueChanged(_ slider: UISlider) {
        valueChanged?(Int(slider.value))
        updateValueLabel()
    }

}
