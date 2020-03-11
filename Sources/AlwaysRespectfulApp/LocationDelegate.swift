//
//  LocationDelegate.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 03/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import AlwaysRespectfully
import AnyLogger


public class LocationDelegate: NSObject {
    public static let shared = LocationDelegate()
    
    public let manager = CLLocationManager()
    
    public let authorizationStatusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    public let didStartMonitoringForRegionSubject = PassthroughSubject<CLRegion, Never>()
    public let didFailMonitoringForRegionSubject = PassthroughSubject<(CLRegion?, Error), Never>()
    public let didEnterRegionSubject = PassthroughSubject<CLRegion, Never>()
    public let didExitRegionSubject = PassthroughSubject<CLRegion, Never>()
    public let insideRegionSubject = PassthroughSubject<CLRegion, Never>()
    public let outsideRegionSubject = PassthroughSubject<CLRegion, Never>()

    
    private override init() {
        super.init()
    }
    
    public func startDelegation() {
        guard manager.delegate == nil else { return }
        
        log.debug("> LocationDelegate startDelegation")
        manager.delegate = self
    }
}


extension LocationDelegate: RegionStore {
    public typealias L = CLLocationCoordinate2D
    public typealias NativeRegion = CLRegion

    public var storedRegions: Set<CLRegion> { Set(manager.monitoredRegions) }
    
    public func add(regions: [Region]) -> AnyPublisher<Void, Error> {
            
        func add(region: Region) -> AnyPublisher<Void, Error> {
            let nativeRegion = region.native
            return startMonitoring(for: nativeRegion)
        }
    
        let publishers = regions.map(add)
        return Publishers.zipMany(publishers)
    }
    
    public func remove(regions: [CLRegion]) {
        func stopMonitoring(for region: CLRegion) { manager.stopMonitoring(for: region) }
        regions.forEach(stopMonitoring)
    }
    
    public var insideRegionPublisher: AnyPublisher<CLRegion, Never> {
        Publishers.Merge(didEnterRegionSubject, insideRegionSubject).eraseToAnyPublisher()
    }
    
    public var outsideRegionPublisher: AnyPublisher<CLRegion, Never> {
        Publishers.Merge(didExitRegionSubject, outsideRegionSubject).eraseToAnyPublisher()
    }
}


extension LocationDelegate: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.debug("> didChangeAuthorization \(status)")
        authorizationStatusSubject.send(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log.debug("> didUpdateLocations \(locations.debugDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.debug("> didStartMonitoringForRegion \(region.identifier)")
        didStartMonitoringForRegionSubject.send(region)
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: Error
    ) {
        log.debug("> monitoringDidFailFor \(String(describing: region?.identifier)) withError \(error.localizedDescription))")
        didFailMonitoringForRegionSubject.send((region, error))
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log.debug("> didEnterRegion \(region.identifier)")
        didEnterRegionSubject.send(region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log.debug("> didExitRegion \(region.identifier)")
        didExitRegionSubject.send(region)
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didDetermineState state: CLRegionState,
        for region: CLRegion
    ) {
        switch state {
        case .unknown:
            log.debug("> didDetermineState for \(region.identifier): unknown")
            
        case .inside:
            log.debug("> didDetermineState for \(region.identifier): inside")
            insideRegionSubject.send(region)
            
        case .outside:
            log.debug("> didDetermineState for \(region.identifier): outside")
            outsideRegionSubject.send(region)
        }
    }
}


extension LocationDelegate {
    
    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    
    func startMonitoring(for region: CLRegion) -> AnyPublisher<Void, Error> {

        func startMonitoring(on _: Subscription) {
            startDelegation()
            log.debug("manager.startMonitoring(for: \(region.debugDescription)")
            manager.startMonitoring(for: region)
        }
        
        let didStart = didStartMonitoringForRegionSubject
            .filter({ $0.identifier == region.identifier })
            .map({ _ in })
            .setFailureType(to: Error.self)
            .logDebug(".didStartMonitoringForRegion \(region.identifier)")
        
        let didFail = didFailMonitoringForRegionSubject
            .filter({ (failedRegion, error) -> Bool in
                switch failedRegion {
                case .some(let failedRegion): return failedRegion.identifier == region.identifier
                case .none: return true
                }
            })
            .tryMap({ (failedRegion, error) throws in
                throw(error)
            })
            .logDebug(".didFailMonitoringForRegion \(region.identifier)")
                
        return Publishers.Merge(didStart, didFail)
            .handleEvents(receiveSubscription: startMonitoring)
            .prefix(1)
            .logDebug(".start monitoring region: \(region.identifier)")
    }
    
    
}
