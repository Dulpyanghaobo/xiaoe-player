//
//  FeedBackViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//

import UIKit
import SnapKit
import Toast

class FeedBackViewController: BaseViewController {
    let tableView = UITableView(frame: .zero, style: .grouped)
    private let viewModel = FeedbackViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "在线反馈"
        setupTableView()
        setupKeyboardObservers()
        viewModel.onStateChanged = { [weak self] in
            self?.view.makeToast("提交成功", duration: 0.66, position: .bottom) {_ in 
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionFooterHeight = 0
        tableView.register(FeedbackOptionCell.self, forCellReuseIdentifier: "FeedbackOptionCell")
        tableView.register(FeedbackTextViewCell.self, forCellReuseIdentifier: "FeedbackTextViewCell")
        tableView.register(ContactInfoCell.self, forCellReuseIdentifier: "ContactInfoCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationFullHeight)
            make.left.right.bottom.equalToSuperview()
        }
        tableView.tableFooterView = createFooterView()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            
            // 确保当前编辑的 cell 可见
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc func submitButtonTapped() {
        viewModel.submitFeedback()
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FeedBackViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.feedbackOptions.count
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "请选择你想要反馈的问题点"
        case 1:
            return "请填写详细的反馈内容"
        case 2:
            return "联系QQ"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackOptionCell", for: indexPath) as! FeedbackOptionCell
            cell.selectionStyle = .none
            let optionViewModel = viewModel.feedbackOptions[indexPath.row]
            cell.configure(with: optionViewModel)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackTextViewCell", for: indexPath) as! FeedbackTextViewCell
            cell.configure(with: "详细描述你遇到的问题")
            cell.onTextChanged = { [weak self] text in
                self?.viewModel.feedbackText = text
            }
            cell.onImagesChanged = { [weak self] images in
                self?.viewModel.images = images
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoCell", for: indexPath) as! ContactInfoCell
            cell.configure(with: "留下您的联系方式，有助于解决您的问题哦～")
            cell.onTextChanged = { [weak self] contactInfo in
                self?.viewModel.contactInfo = contactInfo
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionViewModel = viewModel.feedbackOptions[indexPath.row]
        optionViewModel.toggleSelection()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension FeedBackViewController {
    private func createFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("提交反馈", for: .normal)
        submitButton.backgroundColor = AppColors.themeColor
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        footerView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(133)
            make.height.equalTo(36)
        }
        
        return footerView
    }
}
