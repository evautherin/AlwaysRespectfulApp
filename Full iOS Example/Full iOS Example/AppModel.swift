//
//  AppModel.swift
//  Metro13
//
//  Created by Etienne Vautherin on 20/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import os
import Combine
import SwiftUI
import AlwaysRespectfully
import AlwaysRespectfulApp


class AppModel: ObservableObject {
    static let shared = AppModel()
    
    @Published var services = [
        (name: "Châtillon", image: Image("M13"), latitude: 48.809995, longitude: 2.300354),
        (name: "Invalides", image: Image("M8"), latitude: 48.861005, longitude: 2.313331),
    ].map(GreatService.init)
    
    @Published var locationLaunch = false
    @Published var notifcationLaunch = false
    
    let actions = PassthroughSubject<Action, Never>()
    
    var subscriptions = Set<AnyCancellable>()

    
    enum Action {
        case setLocationLaunch(_ value: Bool)
        case setNotificationLaunch(_ value: Bool)
    }
    

    func setLocationLaunch(value: Bool) {
        actions.send(.setLocationLaunch(value))
    }

    
    func setNotificationLaunch(value: Bool) {
        actions.send(.setNotificationLaunch(value))
    }
    
    
    func setLaunch(options: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let options = options else { return }
        
        let locationLaunchValue = options[UIApplication.LaunchOptionsKey.location]
        let locationLaunch =  (locationLaunchValue as? NSNumber)?.boolValue ?? false
        setLocationLaunch(value: locationLaunch)
        
//        let notificationLaunchValue = options[UIApplication.LaunchOptionsKey.localNotification]
//        let notificationLaunch =  (notificationLaunchValue as? NSNumber)?.boolValue ?? false
    }

    
    func reducer(action: Action) {
        switch action {
        case .setLocationLaunch(let value): locationLaunch = value
        case .setNotificationLaunch(let value): notifcationLaunch = value
        }
    }

    
    func sideEffects(_ locationLaunch: Bool) {
        requestBestAuthorization(locationLaunch)
        
        let predicates = services
            .map(GreatService.predicates)
            .reduce([], +)
        
        AlwaysRespectfulApp
            .monitor(predicates: Set(predicates))
            .sink(receiveCompletion: { (completion) in
                switch (completion) {
                case .finished: os_log("Monitor finished", log: OSLog.default, type: .default)
                case .failure(let error): os_log("Monitor error: %s", log: OSLog.default, type: .error, error.localizedDescription)
                }
            }, receiveValue: GreatService.setStartedValue)
            .store(in: &subscriptions)
    }
    
    
    func add() {
        services.append(GreatService(name: "Cupertino", image: Image("M10"), latitude: 37.334480, longitude: -122.041477))
    }
    
    func requestBestAuthorization(_ locationLaunch: Bool) {
        guard !locationLaunch else { return }
      
        #warning("requestBestAuthorization")
        LocationDelegate.shared.requestAlwaysAuthorization()
        NotificationDelegate.requestAuthorization(options: [.alert, .badge, .sound])
//        AlwaysRespectful.requestBestAuthorization()
    }
}


