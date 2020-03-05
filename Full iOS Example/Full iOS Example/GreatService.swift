//
//  GreatService.swift
//  Metro13
//
//  Created by Etienne Vautherin on 20/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import SwiftUI
import AlwaysRespectfully
import AlwaysRespectfulApp
import AnyLogger


class GreatService: ObservableObject, Identifiable, Location {

    @Published var started = false
    
    let name: String
    let image: Image
    let latitude: Double
    let longitude: Double
    var designation: Designation { .name(name) }
    var id: String { name }

    let actions = PassthroughSubject<Action, Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    enum Action {
        case setStarted(_ value: Bool)
    }
    

    init(name: String, image: Image, latitude: Double, longitude: Double) {
        self.name = name
        self.image = image
        self.latitude = latitude
        self.longitude = longitude

        $started
            .removeDuplicates()
            .sink(receiveValue: startedSideEffects)
            .store(in: &subscriptions)
        
        actions
            .sink(receiveValue: reducer)
            .store(in: &subscriptions)
    }


    var region: Region<GreatService> {
        Region.circle(self, 50.0)
    }


    func predicates() -> [When] {
        [
            When(.inside, region, thenStartedValue: true, on: self, .always),
            When(.outside, region, thenStartedValue: false, on: self, .started)
        ]
    }
    
    
    static func predicates(service: GreatService) -> [When] {
        service.predicates()
    }

    
    func reducer(action: Action) {
        switch action {
        case .setStarted(let value): started = value
        }
    }
}


extension GreatService {
    func setStarted(value: Bool) {
        actions.send(.setStarted(value))
    }

    
    static func setStartedValue(from: When) {
        let service = from.service
        let started = from.thenStartedValue
        service.setStarted(value: started)
    }
    
    
    var bindedStarted: Binding<Bool> {
        Binding(
            get: { self.started },
            set: { (started) in self.setStarted(value: started) }
        )
    }
}


extension GreatService {
    func startedSideEffects(value: Bool) {
        value ? start() : stop()
    }


    func start() {
        log.debug("*** Start \(name) Great Service")
        MessageNotification.notify(title: "\(name) Great Service", body: "Started")
    }


    func stop() {
        log.debug("*** Stop \(name) Great Service")
        MessageNotification.notify(title: "\(name) Great Service", body: "Stopped")
    }
}


extension GreatService: Hashable {
    static func == (lhs: GreatService, rhs: GreatService) -> Bool {
        lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}


#if DEBUG
extension GreatService: CustomDebugStringConvertible {
    var debugDescription: String { name }
}
#endif


