//
//  FileUploadServer.swift
//  AntPlayerH
//
//  Created by i564407 on 8/13/24.
//
//import GCDWebServer
//
//class FileUploadServer {
//    var webServer: GCDWebServer!
//    var fileUploadCompletionHandler: ((String) -> Void)?
//
//    init() {
//        webServer = GCDWebServer()
//
//        // 添加处理文件上传的处理器
//        webServer.addHandler(forMethod: "POST", path: "/upload", request: GCDWebServerRequest.self) { request in
//            // 处理文件上传
//            let fileData = request.remoteAddressData
//            let fileName = request.headers["File-Name"] ?? "uploaded_file" // 获取文件名
//            let filePath = self.saveFile(data: fileData, withName: fileName, inFolder: "mayi") // 保存文件
//            self.fileUploadCompletionHandler?(filePath ?? "") // 调用回调,传递文件路径
//            return GCDWebServerResponse(statusCode: 200) // OK
//        }
//    }
//
//    // 启动服务器并返回URL
//    func startServer() -> String? {
//        webServer.start(withPort: 8080, bonjourName: nil)
//        return getServerURL()
//    }
//
//    // 获取服务器的URL
//    private func getServerURL() -> String? {
//        guard let ipAddress = getIpAddress() else {
//            return nil
//        }
//        return "http://\(ipAddress):8080/upload"
//    }
//
//    // 保存文件的函数
//    func saveFile(data: Data, withName fileName: String, inFolder folderName: String) -> String? {
//        let fileManager = FileManager.default
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        
//        // 创建特定的子文件夹路径
//        let folderURL = documentsURL.appendingPathComponent(folderName)
//        
//        // 检查子文件夹是否存在，不存在则创建
//        if !fileManager.fileExists(atPath: folderURL.path) {
//            do {
//                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                print("Error creating folder: \(error)")
//                return nil
//            }
//        }
//        
//        // 生成文件路径
//        let fileURL = folderURL.appendingPathComponent(fileName)
//        
//        // 保存文件到特定的子文件夹中
//        do {
//            try data.write(to: fileURL)
//        } catch {
//            print("Error saving file: \(error)")
//            return nil
//        }
//        
//        return fileURL.path
//    }
//
//    // 获取设备的IP地址
//    private func getIpAddress() -> String? {
//        var address: String?
//        var ifaddr: UnsafeMutablePointer<ifaddrs>?
//        if getifaddrs(&ifaddr) == 0 {
//            var ptr = ifaddr
//            while ptr != nil {
//                defer { ptr = ptr?.pointee.ifa_next }
//                guard let interface = ptr?.pointee else { return nil }
//                let addrFamily = interface.ifa_addr.pointee.sa_family
//                if addrFamily == UInt8(AF_INET) {
//                    // WiFi interface
//                    guard let name = interface.ifa_name, String(cString: name) == "en0" else { continue }
//                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                    if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
//                        address = String(cString: hostname)
//                    }
//                }
//            }
//            freeifaddrs(ifaddr)
//        }
//        return address
//    }
//}
