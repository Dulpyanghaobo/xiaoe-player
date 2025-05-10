//
//  DeviceManagementViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit

class DeviceManagementViewController: BaseViewController {
    private let tableView = UITableView.init(frame: .zero, style: .plain)
    private let deviceManager = DeviceManager()
    private var devices: [DeviceInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "设备管理"
        setupTableView()
        fetchDeviceList()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceTableViewCell")
        let headerView = DeviceManagementHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        let loginResponse = UserManager.shared.loadLoginResponse()
        guard let userInfo = loginResponse?.userInfo else { return }
        headerView.configure(with: userInfo.avatar ?? "", name: userInfo.username ?? "", desc: "本账号登录过的设备信息，对不熟悉或不常用的设备退出登录，避免隐私泄露，保护网盘资产安全。")
        tableView.tableHeaderView = headerView
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func fetchDeviceList() {
        self.devices = [SystemDeviceConfig.getDeviceInfo()]
//        deviceManager.getDeviceList { [weak self] result in
//            switch result {
//            case .success(let response):
//                guard let devices = response.data?.devices else { return }
//                self?.devices = devices
//                self?.tableView.reloadData()
//            case .failure(let error):
//                print("Failed to fetch device list: \(error)")
//            }
//        }
    }
    private func deleteDevice(at indexPath: IndexPath) {
        let device = devices[indexPath.row]
        if let encodedData = UserDefaults.standard.data(forKey: "PlayerConfig") {
            // 解码数据
            do {
                let decoder = JSONDecoder()
                let playerConfig = try decoder.decode(PlayerConfigResponse.self, from: encodedData)
                if playerConfig.allowedUnbindDevice {
                    deviceManager.deleteDevice(deviceInfo: device) { [weak self] result in
                        switch result {
                        case .success:
                            self?.devices.remove(at: indexPath.row)
                            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        case .failure(let error):
                            print("Failed to delete device: \(error)")
                        }
                    }
                } else {
                    self.view.makeToast("不允许解绑设备")
                }
            } catch {
                print("Failed to decode PlayerConfigResponse: \(error)")
            }
        }
    }
}

extension DeviceManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath) as! DeviceTableViewCell
        let device = devices[indexPath.row]
        cell.configure(with: device)
        cell.deleteButtonAction = { [weak self] in
            self?.deleteDevice(at: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
