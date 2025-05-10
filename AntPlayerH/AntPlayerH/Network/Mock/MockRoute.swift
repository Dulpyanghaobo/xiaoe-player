//
//  MockRoute.swift
//  AntPlayerH
//
//  Created by i564407 on 5/9/25.
//


import Foundation
import Moya

class MockDataRouter {
    static let shared = MockDataRouter()
    private var mapping: [String: String] = [:]

    init() {
        if let url = Bundle.main.url(forResource: "mock_routes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            self.mapping = decoded
        } else {
            print("⚠️ 无法加载 mock_routes.json 或解码失败")
        }
    }

    func fileName(for path: String) -> String? {
        return mapping[path]
    }
}

class MockDataManager {
    static func load(for target: TargetType) -> Data? {
        // 优先从配置映射获取 mock 文件名
        guard let fileName = MockDataRouter.shared.fileName(for: target.path) else {
            print("⚠️ mock_routes.json 中未配置接口: \(target.path)")
            return nil
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ mock 文件不存在: \(fileName).json")
            return nil
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("❌ 读取 mock 数据失败: \(error)")
            return nil
        }
    }
}
