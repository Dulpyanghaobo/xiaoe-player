//
//  QuestionOptionView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//
import UIKit
import SnapKit

class QuestionOptionView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var questions: [QuestionData]?
    var currentQuestion: QuestionData?
    var isAnswerRight: Bool = false
    var options: [String]?
    var showQuestion: ((Bool) -> Void)?
    var answerQuestion: ((String,String) -> Void)?
    private var selectedAnswers = Set<String>()  // 使用 Set 来存储用户选择的
    var answers: String?
    private var currentTime: TimeInterval = 0
    
    private var collectionView: UICollectionView!
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let submitButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.isHidden = true
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        // 设置headerView
        headerView.backgroundColor = .white
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        
        // 设置标题Label
        titleLabel.font = AppFonts.primary18Font
        titleLabel.textColor = AppColors.themeColor
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 设置collectionView
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = .zero // 禁用自动估算大小
        layout.itemSize = CGSize(width: 44, height: 44) // 默认设置一个固定大小
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 16
        addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        registerCells()
        
        // 设置提交按钮
        submitButton.setTitle("提交", for: .normal)
        submitButton.backgroundColor = AppColors.themeColor
        submitButton.layer.cornerRadius = 4
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().inset(12)
            make.width.equalTo(44)
            make.height.equalTo(24)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(submitButton.snp.top).offset(-4)
            make.centerX.equalToSuperview()
        }
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    private func registerCells() {
        collectionView.register(QuestionCell.self, forCellWithReuseIdentifier: QuestionCell.identifier)
        collectionView.register(CalculationCell.self, forCellWithReuseIdentifier: CalculationCell.identifier)
        collectionView.register(VoiceVerificationCell.self, forCellWithReuseIdentifier: VoiceVerificationCell.identifier)
    }
    
    @objc private func submitButtonTapped() {
        answerQuestion?(self.currentQuestion?.bizData?.questionShowUuid ?? "", answers ??  "")
        self.questions?.removeAll(where: { $0 == self.currentQuestion })
        self.currentQuestion = nil
        self.answers = ""
        self.selectedAnswers = Set<String>()
        self.endEditing(true)
    }
    
    func updateAdVDataList(_ question: [QuestionData]) {
        self.questions = question
    }
    
    func updateCurrentTime(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
        updateVisibleQuestion()
    }
    
    private func updateVisibleQuestion() {
        guard let questions = self.questions else { return }
        
        for question in questions {
            if let videoTime = question.videoTime, Int(currentTime) == Int(TimeInterval(videoTime)/1000) {
                self.currentQuestion = question
                break
            }
        }
        
        if let currentQuestion = currentQuestion {
            if currentQuestion.bizData?.questionType != 5 {
                self.isHidden = false
                reloadQuestionData(with: currentQuestion)
                showQuestion?(true)
            }
        } else {
            self.isHidden = true
        }
    }

    
    private func reloadQuestionData(with question: QuestionData) {
        // 确保问题的类型和选项都存在
        guard let bizData = question.bizData, let questionType = bizData.questionType else { return }
        
        // 设置标题
        switch questionType {
        case 0:
            titleLabel.text = "【多选题】"
        case 1:
            titleLabel.text = "【单选题】"
        case 2:
            titleLabel.text = "【判断题】"
        case 3:
            titleLabel.text = "【计算题】"
        case 4:
            titleLabel.text = "【语音验证码】"
        default:
            titleLabel.text = "【未知题型】"
        }
        // 重新加载选项
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.currentQuestion?.bizData?.questionType {
        case 0, 1, 2:
            // 计算非空选项的数量
            let answers = [currentQuestion?.bizData?.answerA, currentQuestion?.bizData?.answerB, currentQuestion?.bizData?.answerC, currentQuestion?.bizData?.answerD]
            return answers.compactMap { $0 }.count
            
        case 3:
            // 计算题通常只需要展示一个表达式
            let answers = [currentQuestion?.bizData?.calcA,currentQuestion?.bizData?.calcType, currentQuestion?.bizData?.calcB, "=", ""]
            return answers.compactMap { $0 }.count
            
        case 4:
            let answers = [currentQuestion?.bizData?.onePlay]
            return answers.compactMap{$0}.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = self.currentQuestion?.bizData?.questionType else {
            return UICollectionViewCell()
        }
        
        switch type {
        case 0, 1, 2:
            // 计算非空选项的数量
            let answers = [currentQuestion?.bizData?.answerA, currentQuestion?.bizData?.answerB, currentQuestion?.bizData?.answerC, currentQuestion?.bizData?.answerD]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestionCell.identifier, for: indexPath) as! QuestionCell
            let chooseLabel = String(UnicodeScalar(65 + indexPath.item)!) // 65 是 'A' 的 ASCII 码
            cell.configure(with: answers[indexPath.item], chooseLabel: chooseLabel)
            // 设置点击事件回调
            cell.onTap = { [weak self] answer in
                guard let self = self, let answer = answer else { return }
                if self.selectedAnswers.contains(answer) {
                    self.selectedAnswers.remove(answer)
                } else {
                    self.selectedAnswers.insert(answer)
                }
                // 更新答案字符串
                self.answers = self.selectedAnswers.joined(separator: ", ")
            }
            return cell
        case 3:
            let answers = [currentQuestion?.bizData?.calcA,currentQuestion?.bizData?.calcType, currentQuestion?.bizData?.calcB, "=", ""]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalculationCell.identifier, for: indexPath) as! CalculationCell
            if indexPath.item == answers.count - 1 {
                // 最后一个cell是输入框
                cell.configure(with: nil, type: .input)
            } else {
                // 其他cell显示label
                cell.configure(with: answers[indexPath.item], type: .label)
            }
            return cell
        case 4:
            let answers = [currentQuestion?.bizData?.onePlay]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VoiceVerificationCell.identifier, for: indexPath) as! VoiceVerificationCell
            cell.configure(with: answers[indexPath.item] ?? 0)
            cell.onInputChanged = { answers in
                self.answers = answers
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = 66.0
        if self.currentQuestion?.bizData?.questionType == 4 {
            width = 200
        } else if self.currentQuestion?.bizData?.questionType == 3{
            if indexPath.item == 4 {
                width = 120
            } else {
                width = 32
            }
        } else {
            width = collectionView.bounds.width / 4
        }
        let itemHeight: CGFloat = 44
        return CGSize(width: width, height: itemHeight)
    }
}
