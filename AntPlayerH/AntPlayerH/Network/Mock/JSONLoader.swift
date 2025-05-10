//
//  JSONLoader.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import Foundation

class JSONLoader {
    static func loadJSON(fromFile fileName: String) -> Data? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("⚠️ 未找到 mock 文件: \(fileName).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            return data
        } catch {
            print("❌ 加载失败 \(fileName).json: \(error)")
            return nil
        }
    }
}
