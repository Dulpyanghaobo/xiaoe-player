//
//  ApiResponse.swift
//  task_management_tool
//
//  Created by i564407 on 5/13/24.
//

import Foundation
import SwiftyJSON

struct ApiResponse<T: Decodable>: Decodable {
    let status: Int
    let message: String
    let data: T?
    
    init?(json: JSON) {
        guard let status = json["status"].int,
              let message = json["message"].string else {
            return nil
        }
        self.status = status
        self.message = message
        // Handle potential throwing initializer for T
        if let dataJSON = json["data"].dictionaryObject {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dataJSON, options: [])
                self.data = try JSONDecoder().decode(T.self, from: jsonData)
            } catch {
                print("Error decoding data: \(error)")
                self.data = nil
            }
        } else {
            self.data = nil
        }
    }
}
