//
//  NotificationDelegate.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 18/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import UserNotifications
import AnyLogger


public class NotificationDelegate: NSObject {
    public static var shared = NotificationDelegate()
    static var center: UserNotificationCenter?
    
    var maskedIdentifiers = Set<String>()
    
    private override init() {
        super.init()
        
        switch NotificationDelegate.center {
        case .none: NotificationDelegate.center = UNUserNotificationCenter.current()
        case .some(_): break
        }
        
        startDelegation()
    }
    
    public func startDelegation() {
//        let center = UNUserNotificationCenter.current()
        var center = NotificationDelegate.center!
        guard center.delegate == nil else { return }
        
        log.debug("> NotificationDelegate startDelegation")
        center.delegate = self
    }
    
    
    public static func set(center: UserNotificationCenter) {
        NotificationDelegate.center = center
    }
}


extension NotificationDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        #warning("Set default method")
        completionHandler()
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let fullOptions = UNNotificationPresentationOptions([.alert, .sound, .badge])
        #warning ("Set default method")
        guard
            notification.request.content.categoryIdentifier == AlwaysRespectful.identifier
            else { completionHandler(fullOptions); return }
        
        log.debug("maskedIdentifiers: \(maskedIdentifiers.debugDescription)")
        let masked = maskedIdentifiers.contains(notification.request.identifier)
        log.debug("Notification masked: \(masked)")
        let options = masked ? [] : fullOptions

        completionHandler(options)
    }
}


extension NotificationDelegate {
    static func removePendingRequests(withIdentifiers identifiers: [String]) {
        center!.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    
    static func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        center!.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}


extension NotificationDelegate {
    public static func requestAuthorization(options: UNAuthorizationOptions) -> Future<Bool, Error> {
        Future({ (promise) in
            center!.requestAuthorization(options: options, completionHandler: { (success, error) in
                switch error {
                case .some(let error): promise(.failure(error))
                case .none: promise(.success((success)))
                }
            })
        })
    }
    
    
    public static func add(request: UNNotificationRequest) -> Future<(Void), Error> {
        Future({ (promise) in
            center!.add(request, withCompletionHandler: { (error) in
                switch error {
                case .some(let error): promise(.failure(error))
                case .none: promise(.success(()))
                }
            })
        })
    }
    
    
    static var pendingNotificationRequests: Future<[UNNotificationRequest], Never> {
        Future({ (promise) in
            center!.getPendingNotificationRequests { (requests) in
                promise(.success(requests))
            }
        })
    }
}


extension NotificationDelegate {
    func addMaskedIdentiers(_ identifiers: Set<String>) {
        log.debug("> add mask for identifiers: \(identifiers.debugDescription)")
        maskedIdentifiers.formUnion(identifiers)
        NotificationDelegate.removeDeliveredNotifications(withIdentifiers: Array(identifiers))
    }
    
    
    func removeMaskedIdentiers(_ identifiers: Set<String>) {
        log.debug("> remove mask for identifiers: \(identifiers.debugDescription)")
        maskedIdentifiers.subtract(identifiers)
    }
}


public protocol UserNotificationCenter {
    var delegate: UNUserNotificationCenterDelegate? { get set }
    
    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping (Bool, Error?) -> Void
    )
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers: [String])
}


extension UNUserNotificationCenter: UserNotificationCenter {}
