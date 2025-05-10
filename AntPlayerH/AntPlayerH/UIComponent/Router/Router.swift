//
//  Router.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import Foundation

protocol Router {
    func navigate(to destination: Destination)
}

enum Destination {
    case login
    case profile(userId: Int)
    case settings
    case course(courseType: CourseType)
}

protocol Mediator {
    func navigate(to destination: Destination)
}

public class AppMediator: Mediator {
    
    
    static let shared = AppMediator()
    
    private var colleagues: [BaseViewController] = []

    private let router: Router

    init() {
        self.router = AppRouter.shared
    }
    
    func navigate(to destination: Destination) {
        router.navigate(to: destination)
    }
    
    func addColleague(_ colleague: BaseViewController) {
        colleagues.append(colleague)
    }
    
    func removeColleague(_ colleague: BaseViewController) {
        colleagues.removeAll { $0 === colleague }
    }
    
    func notify(sender: BaseViewController, event: String) {
        for colleague in colleagues where colleague !== sender {
            colleague.receive(event: event, from: sender)
        }
    }
}
