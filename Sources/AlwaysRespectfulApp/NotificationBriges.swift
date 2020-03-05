//
//  NotificationBriges.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 05/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import CoreLocation
import UserNotifications
import AlwaysRespectfully


extension PositionPredicate {
    public var nativeRegion: CLRegion {
        let rawRegion = region.native
        switch position {
            
        case .inside:
            rawRegion.notifyOnEntry = true
            rawRegion.notifyOnExit = false
                
        case .outside:
            rawRegion.notifyOnEntry = false
            rawRegion.notifyOnExit = true
        }
        return rawRegion
    }
    
    public var notificationRequest: UNNotificationRequest? {
        
        guard let notificationContent = { () -> NotificationPresentation? in
                switch activation {
                case .whenInUse: return .none
                case .always(let content): return content
                }
            }() else { return .none }
        
        let content = UNMutableNotificationContent()
        #warning("Register category")
        content.categoryIdentifier = AlwaysRespectful.identifier
        content.title = notificationContent.title
        content.body = notificationContent.body
        content.sound = notificationContent.sound.native
//        content.userInfo = ["mission": identifier]

        let trigger = UNLocationNotificationTrigger(region: nativeRegion, repeats: true)

        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
    
//    public var request: UNNotificationRequest {
//        nativePredicate()
//    }
    
//    public static func extract(region: CLRegion) -> Region<AnyLocation>? {
//        region.extracted
//    }
}


extension CLRegion {
    public var abstractedPredicate: AnyPositionPredicate? {
        guard
            let region = abstractedRegion,
            let position = abstractedPosition
            else { return .none }
        
        return AnyPositionPredicate(position, region)
    }
}


extension UNNotificationRequest {
    
    public var nativeRegion: CLRegion? {
        guard
            content.categoryIdentifier == AlwaysRespectful.identifier,
            let trigger = trigger as? UNLocationNotificationTrigger
            else { return .none }
        
        return trigger.region
    }
    
    public var abstractedPredicate: AnyPositionPredicate? {
        nativeRegion?.abstractedPredicate
    }
    
    public static func abstractPredicate(from request: UNNotificationRequest) -> AnyPositionPredicate? {
        request.abstractedPredicate
    }
}


extension NotificationSound {
    public var native: UNNotificationSound {
        switch self {
        case .`default`: return UNNotificationSound.default
        case .named(let name): return UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
        }
    }
}


