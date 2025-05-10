//
//  VideoLoader.swift
//  AntPlayerH
//
//  Created by i564407 on 8/15/24.
//

import Foundation
class VideoLoader {
    var videoExt: [String]?
    var onError: ((Error) -> Void)?
    var isLoading: ((Bool) -> Void)?

    func fetchLocalVideos(inFolder folderName: String, completion: @escaping (Bool) -> Void) {
        isLoading?(true)
        
        // Step 1: Fetch allowed video extensions
        CourseManager().getVideoExtension { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let allowedExtensions = response.data else {
                    self.onError?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"]))
                    return
                }
                self.videoExt = allowedExtensions
                // Proceed to scan folder after fetching allowed extensions
                self.scanFolder(folderName, completion: completion)
                
            case .failure(let error):
                self.onError?(error)
            }
        }
    }

    private func scanFolder(_ folderName: String, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        
        // Get the Documents directory and append the "mayi" folder to the path
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mayiFolderURL = documentsURL.appendingPathComponent("mayi")
        
        do {
            // Retrieve the contents of the "mayi" folder
            let files = try fileManager.contentsOfDirectory(atPath: mayiFolderURL.path)
            var courseList = [CourseLocal]()
            
            for file in files {
                let filePath = mayiFolderURL.appendingPathComponent(file).path
                let fileExtension = (file as NSString).pathExtension
                
                // Step 2: Check if the file has an allowed extension
//                if videoExt?.contains(fileExtension) {
                    // Step 3: Calculate MD5
                    if let md5 = getFileMd5(filePath: filePath) {
                        // Step 4: Fetch file attributes
                        if let courseUuid = getFileAttribute(filePath: filePath, attributeName: "videoUid") {
                            let course = CourseLocal(courseUuid: courseUuid, encryMd5: md5)
                            courseList.append(course)
                        }
                    }
//                }
            }
            
            // Step 5: Validate the course list
            validateCourse(courseList: courseList, completion: completion)
            
        } catch {
            completion(false)
            self.onError?(error)
        }
    }

    private func getFileMd5(filePath: String) -> String? {
        var md5Str = [CChar](repeating: 0, count: 33)  // 32 for MD5 hash + 1 for null terminator

        if get_file_md5(filePath, &md5Str) != nil {
            return String(cString: md5Str)
        } else {
            return nil
        }
    }

    private func getFileAttribute(filePath: String, attributeName: String) -> String? {
        var value = [CChar](repeating: 0, count: 128)
        let attr = get_attribute(filePath, attributeName, &value, Int32(value.count))
        if attr == 0 {
            return String(cString: value)
        } else {
            return nil
        }
    }

    private func validateCourse(courseList: [CourseLocal], completion: @escaping (Bool) -> Void) {
        if courseList.isEmpty {
            completion(false) // No valid courses found
        } else {
            // Load video into the player
            CourseManager().loadVideoToPlayer(courseList: courseList) { result in
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.onError?(error)
                    completion(false)
                }
            }
        }
    }
}
