//
//  VideoPlayerViewController+VideoViewModelDelegate.swift
//  AntPlayerH
//
//  Created by i564407 on 8/15/24.
//

import Foundation

extension VideoPlayerViewController: VideoViewModelDelegate {

    func didFetchCourseDetails(_ details: CourseDirectoryPlayInfoResponse, courseResponse: OnlineCoursesResponse, merchantBaseInfoResponse: MerchantBaseInfoResponse, videoPlayInitResponse: VideoPlayInitResponse) {
        self.courseDetailView.updateCourseDetailData(onlineCourseResponse: courseResponse, courseDirectoryPlayInfoResponse: details, merchantBaseInfoResponse: merchantBaseInfoResponse)
        guard let aiCaptionsVOS = videoPlayInitResponse.aiCaptionsVOS, let courseContentTitleVOS = videoPlayInitResponse.courseContentTitleVOS, let adverDatas = videoPlayInitResponse.adverDatas, let questionDatas = videoPlayInitResponse.questionDatas, let aiWaterDatas = videoPlayInitResponse.aiWaterDatas else { return }
        self.updateSubtitles(with: aiCaptionsVOS)
        self.adverView.updateAdVDataList(adverDatas)
        self.adverView.onAdvSelected = { open in
            if open == true {
                self.player?.pause()
            }
        }
        self.questionOptionView.updateAdVDataList(questionDatas)
        self.questionOptionView.showQuestion = { open in
            if open == true {
                if (self.player != nil) {
                    self.player?.pause()
                }
            }
        }
        self.questionOptionView.answerQuestion = {questionUUid, answer in
            self.viewModel?.answerQuestion(questionShowUuid: questionUUid, answer: answer)
        }
        self.videoTitlesView.updateTitles(courseContentTitleVOS)
        self.aiWaterView.updateView(with: aiWaterDatas)
    }
    
    func didFetchComments(_ comments: [CommentRecord]) {
        self.commentsView.updateComments(comments)
    }
    
    func didFetchPersonalNotes(_ notes: [NoteRecord]) {
        self.personalNotesView.updatePersonalNotes(notes)
    }
    
    func didFetchAINotes(_ aiNotes: [AINoteResponse]) {
        aiNotesView.updateAINotes(aiNotes)
    }
    
    func didAddComment(_ message: Bool) {
        if message {
            self.viewModel?.fetchComments(page: 0, size: 20)
        }
    }
    
    func didLikeComment(_ success: Bool) {
        
    }
    
    func didModifyNote(_ success: Bool) {
        
    }
    
    func didAddPersonalNote(_ success: Bool) {
        if success {
            self.viewModel?.fetchPersonalNotes(page: 0, size: 20)
        }
    }
    
    func didSetVideoURL(_ url: URL) {
        
    }
    func didFetchDanmaku(_ danmaku: [DanmakuResponse]) {
        self.bulletCommentsView.updateBulletComments(danmaku)
        barrageController.bulletComments = danmaku
    }
    
    func didAddDanmaku(_ success: Bool) {
        if success {
            self.viewModel?.fetchAllDanmaku()
        }
    }
    
    func didAnswerQuestion(_ success: Bool) {
        self.questionOptionView.isHidden.toggle()
        self.player?.play()
    }
    
}
