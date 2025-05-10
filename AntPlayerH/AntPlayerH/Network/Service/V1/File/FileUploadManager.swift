//
//  FileUploadManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//
import Foundation

class FileUploadManager {
    private let networkManager: NetworkManager<FileUploadService>
    
    init() {
        networkManager = NetworkManager<FileUploadService>()
    }
    
//    func getUploadCredentials(bizCode: String, fileName: String, fileSize: Int64, lastModifyTime: Int64, completion: @escaping (Result<UploadCredentialsResponse, Error>) -> Void) {
//        let fileKey = calculateFileKey(fileName: fileName, fileSize: fileSize, lastModifyTime: lastModifyTime)
//        
//        networkManager.request(target: .getUploadCredentials(bizCode: bizCode, fileKey: fileKey, fileName: fileName, fileSize: fileSize, lastModifyTime: lastModifyTime)) { (result: Result<UploadCredentialsResponse, NetworkError>) in
//            switch result {
//            case .success(let response):
//                completion(.success(response))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
//    func uploadFile(fileData: Data, fileName: String, mimeType: String, bizCode: String, completion: @escaping (Result<String, Error>) -> Void) {
//        let fileSize = Int64(fileData.count)
//        let lastModifyTime = Int64(Date().timeIntervalSince1970)
        
//        getUploadCredentials(bizCode: bizCode, fileName: fileName, fileSize: fileSize, lastModifyTime: lastModifyTime) { [weak self] result in
//            switch result {
//            case .success(let credentials):
//                // Use the credentials to upload the file
//                self?.performUpload(data: fileData, fileName: fileName, mimeType: mimeType, credentials: credentials, completion: completion)
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
//    func getBizCode(completion: @escaping (Result<BizCodeResponse, Error>) -> Void) {
//        networkManager.request(target: .getBizCode) { (result: Result<BizCodeResponse, NetworkError>) in
//            switch result {
//            case .success(let response):
//                completion(.success(response))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    func performUpload(uploadFile: String, data: Data, fileName: String, mimeType: String,  completion: @escaping (Result<ApiResponse<FileResponse>, Error>) -> Void) {
        networkManager.request(target: .uploadFile(bizCode:uploadFile, data: data, fileName: fileName, mimeType: mimeType)) { (result: Result<ApiResponse<FileResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
struct FileResponse: Codable {
    let fileKey: String
    let attachInfoId: Int
    let fileUrl: String
}
