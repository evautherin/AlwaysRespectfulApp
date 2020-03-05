//
//  LocationBridges.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 05/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import CoreLocation
import AlwaysRespectfully

public struct AlwaysRespectful {
    static let identifier = "AlwaysRespectful"
}


extension CLLocationCoordinate2D: Location {
    public var designation: Designation { .unknown }
}


extension BeaconIdentifier {
    var native: CLBeaconIdentityConstraint {
        switch (major) {
            
        case .major(let major, let minor):
            switch minor {
            case .minor(let minor): return CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
            case .any: return CLBeaconIdentityConstraint(uuid: uuid, major: major)
            }
            
        case .any:
            return CLBeaconIdentityConstraint(uuid: uuid)
        }
    }
}


extension CLBeaconIdentityConstraint {
    var extracted: BeaconIdentifier? {
        var majorIdentifier: BeaconMajorIdentifier {
            switch major {
                
            case .some(let major):
                switch minor {
                case .some(let minor): return BeaconMajorIdentifier.major(major, BeaconMinorIdentifier.minor(minor))
                case .none: return BeaconMajorIdentifier.major(major, BeaconMinorIdentifier.any)
                }

            case .none: return BeaconMajorIdentifier.any
            }
        }
        
        return  BeaconIdentifier(uuid: uuid, major: majorIdentifier)
    }
}


extension Region {
    public var native: CLRegion {
        switch self {
            
        case .circle(let center, let radius):
            return CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(center.latitude),
                    longitude: CLLocationDegrees(center.longitude)),
                radius: CLLocationDistance(radius),
                identifier: description
            )
            
        case .beaconArea(let beaconIdentifier):
            return CLBeaconRegion(
                beaconIdentityConstraint: beaconIdentifier.native,
                identifier: description
            )
        }
    }
    
    public func native(identifier: String) -> CLRegion {
        switch self {
            
        case .circle(let center, let radius):
            return CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(center.latitude),
                    longitude: CLLocationDegrees(center.longitude)),
                radius: CLLocationDistance(radius),
                identifier: identifier
            )
            
        case .beaconArea(let beaconIdentifier):
            return CLBeaconRegion(
                beaconIdentityConstraint: beaconIdentifier.native,
                identifier: identifier
            )
        }
    }
    
    public static func extract(region: CLRegion) -> Region<AnyLocation>? {
        region.abstractedRegion
    }
}


extension CLRegion {
    public var abstractedRegion: Region<AnyLocation>? {
        let circleOptional = self as? CLCircularRegion
        let beaconOptional = self as? CLBeaconRegion
        
        switch (circleOptional, beaconOptional) {
            
        case (.some(_), .some(_)):
            return .none
            
        case (.some(let circular), .none):
            let center = circular.center
            return Region.circle(
                AnyLocation(
                    latitude: center.latitude,
                    longitude: center.longitude
                ),
                circular.radius
            )
            
        case (.none, .some(let beacon)):
            return beacon.abstractedRegion
            
        case (.none, .none):
            return .none
        }
    }
}


extension CLRegion {
    public var abstractedPosition: Position? {
        switch (notifyOnEntry, notifyOnEntry) {
        case (false, false): return .none
        case (false, true): return .outside
        case (true, false): return .inside
        case (true, true): return .none
        }
    }
}






