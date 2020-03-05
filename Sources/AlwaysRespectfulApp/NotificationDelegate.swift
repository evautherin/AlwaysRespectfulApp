//
//  NotificationDelegate.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 18/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import CoreLocation
import UserNotifications
import AlwaysRespectfully
import AnyLogger


public class NotificationDelegate: NSObject {
    public static var shared = NotificationDelegate()

    var maskedIdentifiers = Set<String>()
    
    private override init() {
        super.init()
        startDelegation()
    }
    
    public func startDelegation() {
        let center = UNUserNotificationCenter.current()
        guard center.delegate == nil else { return }
        
        log.debug("> NotificationDelegate startDelegation")
        center.delegate = self
    }
}


extension NotificationDelegate: PositionPredicateStore {
    public typealias NativePredicate = UNNotificationRequest

    public var storedPredicates: Future<Set<UNNotificationRequest>, Never> {
        Future({ (promise) in
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests { (requests) in
                promise(.success(Set(requests)))
            }
        })
    }
    
    public func add<Predicate>(predicates: [Predicate]) -> AnyPublisher<Void, Error>
        where Predicate : PositionPredicate {
            
        func add(predicate: Predicate) -> Future<Void, Error>? {
            guard let request = predicate.notificationRequest else { return .none }
            return NotificationDelegate.add(request: request)
        }
    
        let publishers = predicates.compactMap(add)
        return Publishers.zipMany(publishers)
    }
    
    public func remove(predicateIdentifiers: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: predicateIdentifiers)
    }
    
    public func mask(predicateIdentifiers: [String]) {
        maskedIdentifiers.formUnion(Set(predicateIdentifiers))
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: predicateIdentifiers)
    }
    
    public func unmask(predicateIdentifiers: [String]) {
        maskedIdentifiers.subtract(Set(predicateIdentifiers))
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


//extension NotificationDelegate {
//    static func removePendingRequests(withIdentifiers identifiers: [String]) {
//        center.removePendingNotificationRequests(withIdentifiers: identifiers)
//    }
//
//
//    static func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
//        center.removeDeliveredNotifications(withIdentifiers: identifiers)
//    }
//}


extension NotificationDelegate {
    public static func requestAuthorization(options: UNAuthorizationOptions) -> Future<Bool, Error> {
        Future({ (promise) in
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: options, completionHandler: { (success, error) in
                switch error {
                case .some(let error): promise(.failure(error))
                case .none: promise(.success((success)))
                }
            })
        })
    }
    
    
    public static func add(request: UNNotificationRequest) -> Future<(Void), Error> {
        Future({ (promise) in
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                switch error {
                case .some(let error): promise(.failure(error))
                case .none: promise(.success(()))
                }
            })
        })
    }
    
    
//    static var pendingNotificationRequests: Future<[UNNotificationRequest], Never> {
//        Future({ (promise) in
//            center.getPendingNotificationRequests { (requests) in
//                promise(.success(requests))
//            }
//        })
//    }
}


//extension NotificationDelegate {
//    func addMaskedIdentiers(_ identifiers: Set<String>) {
//        log.debug("> add mask for identifiers: \(identifiers.debugDescription)")
//        maskedIdentifiers.formUnion(identifiers)
//        NotificationDelegate.removeDeliveredNotifications(withIdentifiers: Array(identifiers))
//    }
//
//
//    func removeMaskedIdentiers(_ identifiers: Set<String>) {
//        log.debug("> remove mask for identifiers: \(identifiers.debugDescription)")
//        maskedIdentifiers.subtract(identifiers)
//    }
//}


