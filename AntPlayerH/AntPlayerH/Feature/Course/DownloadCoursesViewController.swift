//
//  DownloadCoursesViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/8/24.
//

import UIKit

// 定义下载课程模型
class DownloadedCourse {
    var title: String // 课程标题
    var filePath: String // 下载文件的路径
    var isDownloaded: Bool // 下载状态
    
    init(title: String, filePath: String, isDownloaded: Bool = false) {
        self.title = title
        self.filePath = filePath
        self.isDownloaded = isDownloaded
    }
}


class DownloadCoursesViewController: UIViewController {
    
    private let tableView = UITableView()
    private var downloadedCourses: [DownloadedCourse] = [] // 假设 DownloadedCourse 是您的模型类
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDownloadedCourses()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "下载的课程"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CourseCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadDownloadedCourses() {
        // 从 UserDefaults 或其他存储中加载已下载的课程
        if let downloadedCoursesDict = UserDefaults.standard.dictionary(forKey: "downloadedCourses") as? [String: String] {
            for (title, filePath) in downloadedCoursesDict {
                let course = DownloadedCourse(title: title, filePath: filePath, isDownloaded: true)
                downloadedCourses.append(course)
            }
        }
    }
}

extension DownloadCoursesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        let course = downloadedCourses[indexPath.row]
        cell.textLabel?.text = course.title // 假设 DownloadedCourse 有一个 title 属性
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = downloadedCourses[indexPath.row]
//        playDownloadedVideo(course: course)
    }
    
//    private func playDownloadedVideo(course: DownloadedCourse) {
//        guard let filePath = course.filePath else { return } // 假设 DownloadedCourse 有 filePath 属性
//        let videoPlayer = VideoPlayer(url: URL(fileURLWithPath: filePath))
//        let playerViewController = VideoPlayerViewController(player: videoPlayer, selectedCourseId: course.id, onlineCoursesResponse: <#OnlineCoursesResponse#>)
//        navigationController?.pushViewController(playerViewController, animated: true)
//    }
}
