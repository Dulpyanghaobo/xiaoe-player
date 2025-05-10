//
//  PlayerDetailView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//

import UIKit
@available(iOS 16.0, *)
class CourseDetailView: PlayerDetailView {
    var onlineCourseResponse:  OnlineCoursesResponse?
    
    var courseDirectoryPlayInfoResponse: CourseDirectoryPlayInfoResponse?
    
    var merchantBaseInfoResponse: MerchantBaseInfoResponse?
    
    var cousrInfo: CourseInfo?
    
    var onTap: ((CourseInfo) -> Void)?

    var headerView = CoursePlayerTableHeaderView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 49))
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.backgroundColor = .white
        identifierCell = "CoursePlayerDetailCell"
        registerCells()
        setupTableViewHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func registerCells() {
        tableView.register(CoursePlayerDetailCell.self, forCellReuseIdentifier: "CoursePlayerDetailCell")
        tableView.register(CoursePlayerSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "CoursePlayerSectionHeaderView")
    }
    
    override func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        tableView.register(CoursePlayerDetailCell.self, forCellReuseIdentifier: identifierCell)

        guard let detailCell = cell as? CoursePlayerDetailCell, let courseInfos = onlineCourseResponse?.courseInfos else { return }
        detailCell.configure(with: courseInfos[indexPath.row], selectCousreInfo: self.cousrInfo)
    }
    
    private func setupTableViewHeader() {
        tableView.tableHeaderView = headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CoursePlayerSectionHeaderView") as? CoursePlayerSectionHeaderView else {
            return nil
        }
        guard let merchantBaseInfoResponse = self.merchantBaseInfoResponse else { return UIView.init() }
        headerView.configure(merchantBaseInfoResponse: merchantBaseInfoResponse)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 106
    }
    
    func updateCourseDetailData(onlineCourseResponse: OnlineCoursesResponse, courseDirectoryPlayInfoResponse: CourseDirectoryPlayInfoResponse, merchantBaseInfoResponse: MerchantBaseInfoResponse) {
        self.onlineCourseResponse = onlineCourseResponse
        self.courseDirectoryPlayInfoResponse = courseDirectoryPlayInfoResponse
        self.merchantBaseInfoResponse = merchantBaseInfoResponse
        guard let courseDirectoryPlayInfoResponse = self.courseDirectoryPlayInfoResponse, let onlineCourseResponse = self.onlineCourseResponse  else { return }
        headerView.configure(with: courseDirectoryPlayInfoResponse, onlineCoursesResponse: onlineCourseResponse)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let courseInfos = onlineCourseResponse?.courseInfos else { return 0 }
        return courseInfos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cousrInfo = self.onlineCourseResponse?.courseInfos?[indexPath.row] else { return }
        self.cousrInfo = cousrInfo
        self.onTap?(cousrInfo)
    }
}
