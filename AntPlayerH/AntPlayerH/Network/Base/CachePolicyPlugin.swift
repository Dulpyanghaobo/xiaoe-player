//
//  CachePolicyPlugin.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import Moya

final class CachePolicyPlugin: PluginType {
    private let cache: URLCache

    init(cache: URLCache = URLCache.shared) {
        self.cache = cache
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.cachePolicy = .returnCacheDataElseLoad
        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard case let .success(response) = result else { return }
        let cachedResponse = CachedURLResponse(response: response.response!, data: response.data)
        cache.storeCachedResponse(cachedResponse, for: response.request!)
    }
}
