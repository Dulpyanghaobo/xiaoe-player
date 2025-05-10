//
//  LocalCourseViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/16/24.
//

import UIKit
import ZVRefreshing
import XLActionController
import AVFoundation

public enum CourseType {
    case local
    case online
}

class CourseViewController: BaseViewController {
    
    private var courseType: CourseType
    private let viewModel = CourseViewModel()
    private let loadingView = LoadingView()
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private let emptyView = EmptyView()
    
    private var sortingHeaderView: SortingHeaderView!
    private var currentSortOrder: String = "ASC"
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    init(courseType: CourseType) {
        self.courseType = courseType
        super.init(mediator: .init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.isHidden = true
        emptyView.tableView = self.tableView
    }
    
    func showEmptyView() {
        emptyView.isHidden = false
    }
    
    func hideEmptyView() {
        emptyView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        self.tableView.refreshHeader?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarStyle = .customStyle(title: "蚂蚁播放器", description: "V1.1.0", courseType: courseType)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func addStatusBarBackgroundView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let statusBarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: statusBarHeight))
        statusBarBackgroundView.backgroundColor = AppColors.themeColor // 设置你想要的颜色
        view.addSubview(statusBarBackgroundView)
    }

    private func setupUI() {
        // 设置tableView
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourseInfoCell.self, forCellReuseIdentifier: "CourseCell")
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        tableView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarHeight)
            make.bottom.equalToSuperview()
        }
        
        // 设置loadingView
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }
        setupEmptyView()
        loadingView.isHidden = true
        // 设置排序头部视图
        sortingHeaderView = SortingHeaderView.init(currentSortOrder: .ascending, onSortOrderChanged: {[weak self] sortOrder in
            self?.fetchOnlineCourses(sortOrder: sortOrder)
        }, frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = sortingHeaderView
        tableView.separatorStyle = .none
        // 添加下拉刷新
        setupPullToRefresh()
    }
    
    func setupPullToRefresh() {
        let header = ZVRefreshStateHeader {
            [unowned self] in
            if self.courseType == .online {
                fetchOnlineCourses()
            } else {
                self.viewModel.addLocalVideos(fromFolder: "mayi") {[weak self] success in
                    self?.loadingView.stopLoading()
                    self?.tableView.refreshHeader?.endRefreshing()
                }
            }
        }
        self.tableView.refreshHeader = header
    }
    
    
    private func bindViewModel() {
        viewModel.isLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingView.startLoading()
                } else {
                    self?.loadingView.stopLoading()
                }
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                // 显示错误消息
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func fetchOnlineCourses(sortOrder: SortOrder = .ascending) {
        viewModel.getAllOnlineCourses(order: sortOrder.orderString) { [weak self] in
            self?.updateTableVew()
        }
    }
    func updateTableVew() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshHeader?.endRefreshing()
            self.checkIfEmpty()
        }
    }
}

extension CourseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.onlineCourses[section].isExpanded ? viewModel.onlineCourses[section].course.courseInfos?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = CourseSectionHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 44))
        let courseCatalog = viewModel.onlineCourses[section].course
        headerView.configure(title: courseCatalog.catalogName ?? "", videoCount: courseCatalog.courseInfos?.count ?? 0, isExpanded: viewModel.onlineCourses[section].isExpanded) // 假设默认展开
        headerView.expandButton.tag = section
        headerView.expandButton.addTarget(self, action: #selector(toggleSection(_:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.onlineCourses.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseInfoCell else {
            return UITableViewCell()
        }
        
        guard let course = viewModel.onlineCourses[indexPath.section].course.courseInfos?[indexPath.row] else { return UITableViewCell() }
        cell.configure(with: course)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 处理课程选择逻辑
        if courseType == .online {
            let course = viewModel.onlineCourses[indexPath.section].course
            guard let selectedCourseId =  course.courseInfos?[indexPath.row].courseInfoId else { return }
            guard let selectedCatelog = course.courseCatalogId else { return }
            guard let courseInfo = course.courseInfos?[indexPath.row] else { return }
            self.loadingView.startLoading()
            guard let filePath = viewModel.loadDownloadedFilePath(selectedCatelog: selectedCatelog, courseId: selectedCourseId) else {
                viewModel.getDownloadKeyInfo(selectedCatelog: selectedCatelog, courseId: selectedCourseId)
                self.loadingView.stopLoading()
                return
            }
            
            let videoPlayer = VideoPlayer(url: URL(string: filePath)!, watermark: ["image": "watermark_image.png"])
            
            let playerViewController = VideoPlayerViewController(player: videoPlayer, courseInfo: courseInfo, onlineCoursesResponse: course)
            self.loadingView.stopLoading()
            navigationController?.pushViewController(playerViewController, animated: true)
        } else {
            if let coverUrl = viewModel.onlineCourses[indexPath.section].course.courseInfos?[indexPath.row].coverUrl {
                let fileURL = URL(fileURLWithPath: coverUrl)
                
                // 确保文件路径存在
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let asset = AVAsset(url: fileURL)
                    let playerItem = AVPlayerItem(asset: asset)
                    
                    if playerItem.status == .failed {
                        print("Failed to load video: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                    } else {
                        let player = AVPlayer(playerItem: playerItem)
                        let avPlayerViewController = MyAVPlayerViewController()
                        avPlayerViewController.player = player
                        
                        self.navigationController?.present(avPlayerViewController, animated: true) {
                            player.play()
                        }
                    }
                } else {
                    print("File does not exist at path: \(fileURL.path)")
                }
            } else {
                print("coverUrl is nil")
            }
        }
    }
    
    @objc private func toggleSection(_ sender: UIButton) {
        let section = sender.tag
        viewModel.onlineCourses[section].isExpanded.toggle()
        // 获取该 section 中所有行的 IndexPath
        let indexPaths = (0..<tableView.numberOfRows(inSection: section)).map {
            IndexPath(row: $0, section: section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    private func checkIfEmpty() {
        if self.courseType == .online {
            if self.viewModel.onlineCourses.isEmpty  {
                showEmptyView()
            } else {
                hideEmptyView()
            }
        } else {
            if self.viewModel.onlineCourses.isEmpty {
                showEmptyView()
            } else {
                hideEmptyView()

            }
        }
    }
}
