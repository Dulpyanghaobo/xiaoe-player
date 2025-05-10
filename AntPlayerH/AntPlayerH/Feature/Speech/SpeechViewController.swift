//
//  SpeechViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/15/24.
//
import UIKit
import Speech

class SpeechViewController: UIViewController, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_CN"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始录音", for: .normal)
        button.addTarget(self, action: #selector(startRecording(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer.delegate = self
        requestSpeechAuthorization()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied, .restricted, .notDetermined:
                    self.startButton.isEnabled = false
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    @objc private func startRecording(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            startButton.setTitle("开始录音", for: .normal)
        } else {
            startRecording()
            startButton.setTitle("停止录音", for: .normal)
        }
    }
    
    private func startRecording() {
        // 清理之前的识别任务
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("音频会话设置失败: \(error)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopRecording()
            }
        })
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
        }
//        
//        inputNode.prepare()
//        do {
//            try inputNode.start()
//        } catch {
//            print("输入节点启动失败: \(error)")
//        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("音频引擎启动失败: \(error)")
        }
        
        textView.text = "请开始说话..."
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        recognitionTask = nil
    }
}
