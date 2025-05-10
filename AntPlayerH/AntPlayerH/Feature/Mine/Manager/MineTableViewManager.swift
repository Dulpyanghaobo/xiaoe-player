//
//  MineTableViewManager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
// 首先，定义一个枚举来表示不同的表格行类型
enum MineTableRowType {
    case identityVerification
    case helpCenter
    case softwareSettings
    case aboutAnt
    case aboutApp
    case logout
}

// 定义一个协议来处理表格行的点击事件
protocol MineTableViewManagerDelegate: AnyObject {
    func didSelectRow(type: MineTableRowType)
}

class MineTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: MineTableViewManagerDelegate?
    
    private let rowTypes: [MineTableRowType] = [
        .identityVerification,
        .helpCenter,
        .softwareSettings,
        .aboutAnt,
        .aboutApp,
        .logout
    ]

    func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        return tableView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = .none
        
        let rowType = rowTypes[indexPath.row]
        switch rowType {
        case .identityVerification:
            cell.configure(iconName: "bangzhuzhongxin_icon", title: "实名认证")
        case .helpCenter:
            cell.configure(iconName: "bangzhuzhongxin_icon", title: "帮助中心")
        case .softwareSettings:
            cell.configure(iconName: "bangzhuzhongxin_icon", title: "软件设置")
        case .aboutAnt:
            cell.configure(iconName: "bangzhuzhongxin_icon", title: "关于蚂蚁")
        case .aboutApp:
            cell.configure(iconName: "guanyuyingyong_icon", title: "关于应用")
        case .logout:
            cell.configure(iconName: "tuichudenglu_icon", title: "退出登录")
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = rowTypes[indexPath.row]
        delegate?.didSelectRow(type: rowType)
    }
}
