//
//  MessageNotification.swift
//  Metro13
//
//  Created by Etienne Vautherin on 26/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import UserNotifications
import AlwaysRespectfulApp
import AnyLogger


struct MessageNotification {
    static var subscription: AnyCancellable?

    static func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "MessageNotification"
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: "message", content: content, trigger: .none)

        subscription = NotificationDelegate.add(request: request)
            .sink(receiveCompletion: { (completion) in
                switch (completion) {
                case .finished: log.debug("'\(title), \(body)' message request added")
                case .failure(let error): log.error(error.localizedDescription)
                }
            }, receiveValue: { _ in })
    }
}
