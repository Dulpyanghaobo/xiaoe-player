//
//  IPManager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import Foundation

class IpManager {
    static func getIPAddress(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://ipinfo.io/ip")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                completion(.failure(NSError(domain: "InvalidData", code: -1, userInfo: nil)))
                return
            }
            completion(.success(ip))
        }
        task.resume()
    }

    static func getLocation(ip: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://ipinfo.io/\(ip)/json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let location = json["city"] as? String else {
                completion(.failure(NSError(domain: "InvalidData", code: -1, userInfo: nil)))
                return
            }
            completion(.success(location))
        }
        task.resume()
    }
}
