//
//  FileDownloadManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/23/24.
//

import UIKit
import Tiercel
import AVFoundation

class FileDownloadManager {

    private var sessionManager: SessionManager
    
    var onDownloadStart: (() -> Void)?
    var onDownloadProgress: ((Float, Int, Int) -> Void)?
    var onDownloadComplete: ((Bool, String?, Int) -> Void)?
    
    init() {
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager
        setupManager()
    }
    
    private func setupManager() {
        sessionManager.progress { [weak self] (manager) in
            self?.updateUI()
        }.completion { [weak self] manager in
            self?.updateUI()
            if manager.status == .succeeded {
                // 下载成功
            } else {
                // 其他状态
            }
        }
    }
    
    func startDownload(urlStr: String) {
        guard let downloadURL = URL(string: urlStr) else { return }
        onDownloadStart?()
        
        sessionManager.download(downloadURL)?
            .progress { [weak self] task in
                let progress = Float(task.progress.completedUnitCount) / Float(task.progress.totalUnitCount)
                
                self?.onDownloadProgress?(progress, Int(task.progress.completedUnitCount), Int(task.progress.totalUnitCount))
            }
            .completion { [weak self] task in
                let success = task.status == .succeeded
                let filePath = success ? task.filePath : nil
                let relativePath = self?.extractRelativePath(from: filePath)
                self?.onDownloadComplete?(success, relativePath, Int(task.progress.totalUnitCount))
            }
    }
    
    func totalStart() {
        sessionManager.totalStart { [weak self] _ in
            self?.updateUI()
        }
    }
    
    private func extractRelativePath(from fullPath: String?) -> String? {
        guard let fullPath = fullPath else { return nil }
        if let range = fullPath.range(of: "Caches") {
            return String(fullPath[range.lowerBound...])
        }
        return nil
    }
    
    func totalSuspend() {
        sessionManager.totalSuspend() { [weak self] _ in
            self?.updateUI()
        }
    }
    
    func totalCancel() {
        sessionManager.totalCancel() { [weak self] _ in
            self?.updateUI()
        }
    }
    
    func totalRemove() {
        sessionManager.totalRemove(completely: false) { [weak self] _ in
            self?.updateUI()
        }
    }
    
    func clearDisk() {
        sessionManager.cache.clearDiskCache()
        updateUI()
    }
    
    func updateConfiguration(maxConcurrentTasksLimit: Int, allowsCellularAccess: Bool) {
        sessionManager.configuration.maxConcurrentTasksLimit = maxConcurrentTasksLimit
        sessionManager.configuration.allowsCellularAccess = allowsCellularAccess
    }
    
    private func updateUI() {
        let sessionManager = self.getSessionManager()
        print("总任务：\(sessionManager.succeededTasks.count)/\(sessionManager.tasks.count)")
        print("总速度：\(sessionManager.speedString)")
        print("剩余时间： \(sessionManager.timeRemainingString)")
        print("%.2f", sessionManager.progress.fractionCompleted)
    }
    
    func getSessionManager() -> SessionManager {
        return sessionManager
    }
    
    func getFullPath(for relativePath: String?) -> String? {
        guard let relativePath = relativePath else { return nil }
        let sandboxPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let fullPath = sandboxPath.appendingPathComponent(relativePath).path
        return fullPath
    }
    
    func validateFile(at path: String, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let fullPath = self.getFullPath(for: path)
        if fileManager.fileExists(atPath: fullPath ?? "") {
            // File exists, now check if it can be played
            let fileURL = URL(fileURLWithPath: fullPath ?? "")
            completion(true)
        } else {
            // File does not exist
            completion(false)
        }
    }
}
