//
//  CommentNoteManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation


class CommentNoteManager {
    let networkManager: NetworkManager<CommentNoteService>
    
    init() {
        networkManager = NetworkManager<CommentNoteService>()
    }
    
    func addComment(courseInfoId: Int, courseCatalogId: Int?, content: String, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .addComment(courseInfoId: courseInfoId, courseCatalogId: courseCatalogId, content: content)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getCourseComments(courseInfoId: Int, page: Int, size: Int, completion: @escaping (Result<ApiResponse<CommentListResponse>, Error>) -> Void) {
        networkManager.request(target: .getCourseComments(courseInfoId: courseInfoId, page: page, size: size)) { (result: Result<ApiResponse<CommentListResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func likeComment(courseCommentId: Int, like: Bool, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .likeComment(courseCommentId: courseCommentId, like: like)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getPersonalNoteDetail(id: Int, completion: @escaping (Result<ApiResponse<NoteDetailResponse>, Error>) -> Void) {
        networkManager.request(target: .getPersonalNoteDetail(id: id)) { (result: Result<ApiResponse<NoteDetailResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getPersonalNotes(courseInfoId: Int, page: Int, size: Int, completion: @escaping (Result<ApiResponse<NoteListResponse>, Error>) -> Void) {
        networkManager.request(target: .getPersonalNotes(courseInfoId: courseInfoId, page: page, size: size)) { (result: Result<ApiResponse<NoteListResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getAINotes(id: Int, completion: @escaping (Result<ApiResponse<[AINoteResponse]>, Error>) -> Void) {
        networkManager.request(target: .getAINotes(id: id)) { (result: Result<ApiResponse<[AINoteResponse]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func modifyNote(id: Int, content: String, noteType: Int, delFileKeys: [String], sucessFileKey: [String], completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .modifyNote(id: id, content: content, noteType: noteType, delFileKeys: delFileKeys, sucessFileKey: sucessFileKey)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func addPersonalNote(courseInfoId: Int, content: String, noteType: Int, delFileKeys: [String], sucessFileKey: [String], completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .addPersonalNote(courseInfoId: courseInfoId, content: content, noteType: noteType, delFileKeys: delFileKeys, sucessFileKey: sucessFileKey)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}
