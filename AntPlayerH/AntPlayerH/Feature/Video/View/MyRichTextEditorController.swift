//
//  MyRichTextEditorViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/13/24.
//
import UIKit
import SnapKit
import STTextView
//import ZSSBarButtonItem

class MyRichTextEditorController: ZSSRichTextEditor {
    
    
    typealias CameraButtonCallback = (@escaping (String) -> Void) -> Void

    var cameraButtonCallback: CameraButtonCallback?

    
    var onTap: ((String) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let html = """
        <h3>请输入标题</h3>
        <p>说点什么吧~</p>
        """

        self.shouldShowKeyboard = false
        self.alwaysShowToolbar = true
        self.placeholder = """
        <h1>请输入标题</h1>
        <p>说点什么吧~</p>
        """

        // Set Custom CSS
        let customCSS = ""
        self.setCSS(customCSS)
        
        self.baseURL = URL(string: "http://www.baidu.com")
        self.setHTML(html)
        
        // Set up the editor
        self.formatHTML = true
        
        // Set initial HTML content
        self.setHTML("<p>Welcome to ZSSRichTextEditor!</p>")
        self.title = "个人笔记"
        
        // Export HTML
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(exportHTML))
        self.enabledToolbarItems = [ZSSRichTextEditorToolbarNone];

//        ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapCustomToolbarButton:)];
        let flagItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "flag.fill"), style: .plain, target: self, action: #selector(didTapCustomToolbarButton))
        let cameraItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "camera.fill"), style: .plain, target: self, action: #selector(didTapCustomCameraToolbarButton))
        let imageItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "photo.fill"), style: .plain, target: self, action: #selector(didTapCustomPhotoToolbarButton))
        let boldItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "bold"), style: .plain, target: self, action: #selector(didTapCustomBoldToolbarButton))
        let colorItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "character"), style: .plain, target: self, action: #selector(didTapCustomColorToolbarButton))
        let UndoItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(didTapCustomUndoItembarButton(sender:)))
        let redoItem = ZSSBarButtonItem.init(image: UIImage.init(systemName: "arrow.uturn.forward"), style: .plain, target: self, action: #selector(didTapCustomredoItembarButton(sender:)))

//        [self addCustomToolbarItem:item];
        self.addCustomToolbarItem(flagItem)
        self.addCustomToolbarItem(cameraItem)
        self.addCustomToolbarItem(imageItem)
        self.addCustomToolbarItem(boldItem)
        self.addCustomToolbarItem(colorItem)
        self.addCustomToolbarItem(UndoItem)
        self.addCustomToolbarItem(redoItem)
        self.toolbarItemTintColor = UIColor.black
        self.setHTML(html)
    }
    
    @objc func exportHTML() {
        getHTML { result, error in
            if let error = error {
                print("Error getting HTML: \(error)")
            } else if let result = result {
                print(result)
                self.navigationController?.popViewController(animated: true)
                self.onTap?(result as! String)
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc override func showInsertURLAlternatePicker() {
        self.dismissAlertView()
        presentPhotoPicker()
    }
    
    @objc func didTapCustomToolbarButton() {
        self.setTimeStamp("01:42:39")
    }
    
    @objc func didTapCustomCameraToolbarButton() {
        cameraButtonCallback? { [weak self] url in
              // 在这里接收回调并处理URL
              print("Received URL: \(url)")
            
//              self?.insertImage(url)
          }
        print("didTapCustomCameraToolbarButton")
    }
    
    @objc func didTapCustomColorToolbarButton() {
        print("didTapCustomCameraToolbarButton")
    }
    
    @objc func didTapCustomPhotoToolbarButton() {
        self.insertImageFromDevice()
    }
    
    @objc func didTapCustomBoldToolbarButton() {
        self.setBold()
    }

    @objc func didTapCustomUndoItembarButton(sender: ZSSBarButtonItem) {
        self.undo(sender)
    }
    @objc func didTapCustomredoItembarButton(sender: ZSSBarButtonItem) {
        self.redo(sender)
    }
    
    private func presentPhotoPicker() {
        guard let viewController = self.view.findViewController() else { return }
        PhotoPicker.presentPhotoPicker(from: viewController, selectionLimit: 1) { [weak self] selectedImages in
            
        }
    }

    override func editorDidChange(withText text: String, andHTML html: String) {
        print("Text Has Changed: \(text)")
        print("HTML Has Changed: \(html)")
    }
    
    override func hashtagRecognized(withWord word: String) {
        print("Hashtag has been recognized: \(word)")
    }
    
    override func mentionRecognized(withWord word: String) {
        print("Mention has been recognized: \(word)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
