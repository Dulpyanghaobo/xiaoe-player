//
//  FaceViewModel.swift
//  AntPlayerH
//
//  Created by i564407 on 8/11/24.
//

import Foundation

class FaceViewModel {
    var faceSdkSignResponse: FaceSdkSignResponse?

    // Configure the ViewModel with the SDK response
    func configure(with response: FaceSdkSignResponse) {
        self.faceSdkSignResponse = response
    }



}
