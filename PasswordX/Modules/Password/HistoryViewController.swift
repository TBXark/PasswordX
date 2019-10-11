//
//  HistoryViewController.swift
//  PasswordX
//
//  Created by TBXark on 2019/10/10.
//  Copyright © 2019 TBXark. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    
    var didSelectId: ( (String) -> Void )?

    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private var dataSource = PasswordConfigService.shared.identityHistory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViewController()
    }
        
    func layoutViewController() {
        self.title = "History"
        view.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(view)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "text")
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = QuickBarButton.build(title: "Close", action: {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        self.navigationItem.rightBarButtonItem = QuickBarButton.build(title: "Edit", action: {[weak self] _ in
            self?.tableView.isEditing.toggle()
        })
    }
}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectId?(dataSource[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        tableView.beginUpdates()
        PasswordConfigService.shared.removeIdentity(id: dataSource.remove(at: indexPath.row))
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.attributedText = NSAttributedString(text: dataSource[indexPath.row], color: UIColor.darkGray, font: UIFont.systemFont(ofSize: 14))
        return cell
    }
    
}
