//
//  ConsoleVC.swift
//  Ralyo
//
//  Created by ray on 2017/12/15.
//  Copyright © 2017年 ray. All rights reserved.
//

import UIKit
import MessageUI


let cellReuseId = "cellReuseId"

class ConsoleVC: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    class Cell: UITableViewCell {
        
        var label: UILabel?
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.backgroundColor = .clear
            label = UILabel.init()
            self.addSubview(label!)
            label!.numberOfLines = 0
            label!.lineBreakMode = .byCharWrapping
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            label?.frame = self.bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    weak var window: UIWindow?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    struct fieldConst {
        static let height: CGFloat = 25
        static let leftPading: CGFloat = 35
    }
    
    lazy var inputTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect.init(x: fieldConst.leftPading, y: 0, width: self!.view.bounds.width - fieldConst.leftPading, height: fieldConst.height))
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.placeholder = "Add log"
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth]
        return textField
        }()
    
    lazy var filterTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect.init(x: fieldConst.leftPading, y: 0, width: self!.view.bounds.width - fieldConst.leftPading, height: fieldConst.height))
        self!.view.addSubview(textField)
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.placeholder = "Filter"
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        textField.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth]
        return textField
    }()

    lazy var switchToInputBtn: UIButton = { [weak self] in
        let btn = UIButton.init(type: .custom)
        btn.setTitle("log", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.orange, for: .selected)
        btn.setTitleColor(.orange, for: [.selected, .highlighted])
        btn.frame = CGRect.init(x: 0, y: 0, width: fieldConst.leftPading, height: fieldConst.height/2)
        btn.autoresizingMask = [.flexibleWidth, .flexibleRightMargin]
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.font = .systemFont(ofSize: 10)
        btn.addTarget(self!, action: #selector(switchBtnTapped), for: .touchUpInside)
        return btn
        }()
    
    lazy var switchToFilterBtn: UIButton = { [weak self] in
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Filter", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.orange, for: .selected)
        btn.setTitleColor(.orange, for: [.selected, .highlighted])
        btn.frame = CGRect.init(x: 0, y: fieldConst.height/2, width: fieldConst.leftPading, height: fieldConst.height/2)
        btn.autoresizingMask = [.flexibleWidth, .flexibleRightMargin]
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.font = .systemFont(ofSize: 10)
        btn.addTarget(self!, action: #selector(switchBtnTapped), for: .touchUpInside)
        return btn
        }()
    
    
    lazy var textFieldView: UIView = { [weak self] in
        let height: CGFloat = 30
        let view = UIView.init(frame: CGRect.init(x: 0, y: self!.view.bounds.height - fieldConst.height, width: self!.view.bounds.width, height: fieldConst.height))
        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(inputTextField)
        view.addSubview(filterTextField)
        
        view.addSubview(self!.switchToInputBtn)
        view.addSubview(self!.switchToFilterBtn)

        inputTextField.isHidden = true
        self!.switchToFilterBtn.isSelected = true
        self!.view.addSubview(view)
        
        return view
    }()
    
    @objc func switchBtnTapped(sender: UIButton) {
        if sender == self.switchToFilterBtn {
            self.switchToInputBtn.isSelected = false
            sender.isSelected = true
            self.inputTextField.isHidden = true
            self.filterTextField.isHidden = false
            self.filterTextField.becomeFirstResponder()
        } else {
            self.switchToFilterBtn.isSelected = false
            sender.isSelected = true
            self.inputTextField.isHidden = false
            self.filterTextField.isHidden = true
            self.inputTextField.becomeFirstResponder()
        }
    }
    
    lazy var tableView: UITableView = { [weak self] in
        let tv = UITableView.init(frame: self!.view.bounds, style: UITableViewStyle.plain)
        tv.backgroundColor = .black
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(Cell.self, forCellReuseIdentifier: cellReuseId)
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self!.view.addSubview(tv)
        tv.contentInset = .init(top: 50, left: 0, bottom: fieldConst.height, right: 0)
        return tv
    }()
    
    lazy var closeBtn: UIButton = { [weak self] in
        let btn = UIButton.init(type: .custom)
        btn.setTitle("×", for: .normal)
        btn.titleLabel!.font = UIFont.systemFont(ofSize: 30)
        btn.frame = CGRect.init(x: 5, y: 5 + (self!.prefersStatusBarHidden ? 10 : 0), width: 30, height: 30)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        self!.view.addSubview(btn)
        return btn
    }()
    
    lazy var actionsBtn: UIButton = { [weak self] in
        let btn = UIButton.init(type: .infoLight)
        btn.frame = CGRect.init(x: self!.view.bounds.width - 35, y: 5 + (self!.prefersStatusBarHidden ? 10 : 0), width: 30, height: 30)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(additionalActions), for: .touchUpInside)
        btn.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        self!.view.addSubview(btn)
        return btn
    }()
    
    weak var keyboardObserver: AnyObject?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        let _ = self.tableView
        let _ = self.textFieldView
        let _ = self.closeBtn
        let _ = self.actionsBtn
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: {[weak self] noti in
            if let frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, let textFieldView = self?.textFieldView, let tableView = self?.tableView {
                textFieldView.frame.origin.y = frame.origin.y - textFieldView.bounds.height
                tableView.frame.size.height = textFieldView.frame.origin.y
            }
        })

        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapView)))
        self.filterTextField.addTarget(self, action: #selector(filterEditingChanged), for: .editingChanged)
    }
    
    deinit {
        if let observer = self.keyboardObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @objc func didTapView() {
        self.view.endEditing(true)
    }
    
    @objc func filterEditingChanged() {

        if Console.logs.count > 0, let text = self.filterTextField.text, text.count > 0  {
            filterQueue.async {
                let logs = Console.logs.filter({ log -> Bool in
                    return log.content.contains(text)
                })
                DispatchQueue.main.async {
                    if text.count > 0, text == self.filterTextField.text {
                        self.filteredLogs = logs
                        self.reloadData()
                    }
                }
            }
        } else {
            self.reloadData()
        }
    }
    
    
    func show() {
        if let topVC = self.window?.topViewController(), topVC.presentedViewController != self {
            topVC.present(self, animated: true, completion: nil)
        }
    }
    
    func reloadData() {
        self.attrForIndexPath.removeAll()
        self.tableView.reloadData()
        if self.filteredLogs.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.filteredLogs.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
    @objc func close() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func additionalActions() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let defaultActions = [
            UIAlertAction(title: "send log by mail", style: .default) { action in
                if let data = DiskOutput.fileData {
                    let composeViewController = MFMailComposeViewController()
                    composeViewController.mailComposeDelegate = self
                    composeViewController.setSubject("Console Log")
                    composeViewController.addAttachmentData(data, mimeType: "Plain text", fileName: DiskOutput.curFileName!)
                    self.present(composeViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.init(title: "Notice!", message: "No log, find history logs in: " + DiskOutput.outputPathPrefix, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            },
            UIAlertAction(title: "clear", style: .default) { (action: UIAlertAction) in
                self.filteredLogs.removeAll()
                Console.clear()
            }
        ]
        for action in defaultActions{
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if self.inputTextField.isFirstResponder || self.filterTextField.isFirstResponder {
            return
        }
        //self.textFieldView.frame = CGRect.init(x: 0, y: size.height - fieldConst.height, width: size.width, height: fieldConst.height)
        //self.tableView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: self.textFieldView.frame.origin.y)
    }
    
    var attrForIndexPath: [IndexPath: NSAttributedString] = [:]
    
    var _filteredLogs: [Console.Log]?
    var filteredLogs: [Console.Log] {
        get {
            if let text = filterTextField.text {
                return text.count > 0 ? _filteredLogs ?? Console.logs : Console.logs
            }
            return Console.logs
        }
        set(new) {
            _filteredLogs = new
        }
    }
    var filterQueue = DispatchQueue.init(label: "ConsoleVC.filterQueue", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}

extension ConsoleVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLogs.count
    }
    
    static func attriForLog(log: Console.Log) -> NSAttributedString {
        let timeStamped = NSMutableAttributedString(string: Console.dateFormatter.string(from: log.date) + ": ")
        var range = NSRange(location: 0, length: timeStamped.length)
        
        timeStamped.addAttributes(Console.textAppearance, range: range)
        
        let text = NSMutableAttributedString(string: log.content)
        range = NSRange(location: 0, length: text.length)
        
        text.addAttributes(Console.textAppearance, range: range)
        text.addAttribute(.foregroundColor, value: log.color, range: range)
        
        timeStamped.append(text)
        timeStamped.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)], range: NSRange.init(location: 0, length: timeStamped.length))
        return timeStamped
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let attr = attrForIndexPath[indexPath] ?? ConsoleVC.attriForLog(log: filteredLogs[indexPath.row])
        attrForIndexPath[indexPath] = attr
        let bound = attr.boundingRect(with: CGSize.init(width: tableView.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return bound.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as! Cell
        cell.label!.attributedText = attrForIndexPath[indexPath] ?? ConsoleVC.attriForLog(log: filteredLogs[indexPath.row])
        attrForIndexPath.removeValue(forKey: indexPath)
        return cell
    }
}

extension ConsoleVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  textField == self.inputTextField, let text = textField.text, text.count > 0 {
            Console.print(text)
            textField.text = nil
            filterEditingChanged()
        }
        return false
    }
    
}

extension ConsoleVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIWindow {
    
    func topViewController(_ base: UIViewController? = nil) -> UIViewController? {
        guard let base = base ?? self.rootViewController else {
            return nil
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}


