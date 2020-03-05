//
//  When.swift
//  Full iOS Example
//
//  Created by Etienne Vautherin on 29/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import AlwaysRespectful
import AnyLogger


struct When: PositionPredicate {

    let position: Position
    let region: Region<GreatService>
    let thenStartedValue: Bool
    let service: GreatService
    let activation: Activation
    
    struct Presentation: NotificationPresentation {
        let service: GreatService
        
        var title: String {
            NSString.localizedUserNotificationString(
                forKey: "startServiceTitle",
                arguments: [service.name]
            )
        }
        let body = NSString.localizedUserNotificationString(
            forKey: "startServiceBody",
            arguments: .none
        )
        let sound = NotificationSound.default
    }
    
    
    enum Mode {
        case started
        case always
    }
    

    init(_ position: Position, _ region: Region<GreatService>, thenStartedValue: Bool, on service: GreatService, _ mode: Mode) {
        self.position = position
        self.region = region
        self.thenStartedValue = thenStartedValue
        self.service = service
        switch mode {
        case .started: self.activation = .whenInUse
        case .always: self.activation = .always(Presentation(service: service))
        }
    }
}


extension When: Hashable {
    static func == (lhs: When, rhs: When) -> Bool {
        lhs.position == rhs.position &&
        lhs.region == rhs.region &&
        lhs.thenStartedValue == rhs.thenStartedValue &&
        lhs.service == rhs.service
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(region)
        hasher.combine(thenStartedValue)
        hasher.combine(service)
    }
}


#if DEBUG
extension When: CustomDebugStringConvertible {
    var debugDescription: String {
        var actionString: String {
            thenStartedValue ? "Start" : "Stop"
        }
        return "\(actionString) \(activation.description) service \(service.description) when \(position.description) \(region.description)"
    }
}
#endif


