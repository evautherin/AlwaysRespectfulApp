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


extension CLLocationCoordinate2D {
    func isEqual(to location: Location) -> Bool {
        latitude == location.latitude && longitude == location.longitude
    }

}


extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}


extension Location {
    var native: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude)
        )
    }
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
    var abstractedIdentifier: BeaconIdentifier? {
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
        case .circle(let latitude, let longitude, let radius, _):
            return CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                radius: CLLocationDistance(radius),
                identifier: self.description
            )
        case .beaconArea(let beaconIdentifier):
            return CLBeaconRegion(
                beaconIdentityConstraint: beaconIdentifier.native,
                identifier: description
            )
        }
    }
}


extension CLRegion {
    public var abstractedRegion: Region? {
        let circleOptional = self as? CLCircularRegion
        let beaconOptional = self as? CLBeaconRegion
        
        switch (circleOptional, beaconOptional) {
        case (.some(let circular), .none):
            return Region.circle(
                circular.center.latitude,
                circular.center.longitude,
                circular.radius,
                .unknown
            )
        case (.none, .some(let beacon)):
            return beacon.abstractedRegion
        case (.some(_), .some(_)), (.none, .none):
            return .none
        }
    }
}


extension CLRegion: RegionEquatable {
    public func isEqual(to region: Region) -> Bool {
        guard let abstractedRegion = abstractedRegion else { return false }
        
        switch (abstractedRegion, region) {
        case (.circle(let latitude, let longitude, let radius, _),
              .circle(let regionLatitude, let regionLongitude, let regionRadius, _)) :
            return latitude == regionLatitude &&
                longitude == regionLongitude &&
                radius == regionRadius
        case (.beaconArea(let identifier), .beaconArea(let regionIdentifier)) :
            return identifier == regionIdentifier
        case (.circle(_, _, _, _), .beaconArea(_)), (.beaconArea(_), .circle(_, _, _, _)) :
            return false
        }
    }
}








