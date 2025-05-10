//
//  WebViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var urlString: String

    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebPage()
    }

    private func setupWebView() {
        webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadWebPage() {
        if let url = URL(string: "https://www.baidu.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
