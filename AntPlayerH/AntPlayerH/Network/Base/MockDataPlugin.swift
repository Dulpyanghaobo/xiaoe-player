//
//  MockDataPlugin.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import Moya

class MockDataPlugin: PluginType {
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        switch result {
        case .success:
            return result
        case .failure:
            if let mockData = MockDataManager.load(for: target) {
                print("📦 使用 mock 数据: \(target.path)")
                let response = Response(statusCode: 200, data: mockData)
                return .success(response)
            }
            return result
        }
    }
}
