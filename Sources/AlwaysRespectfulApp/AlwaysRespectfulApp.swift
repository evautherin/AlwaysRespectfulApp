//
//  AlwaysRespectfulApp.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 05/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import AlwaysRespectfully


public struct AlwaysRespectfulApp<Predicate> where Predicate: Hashable, Predicate: PositionPredicate {
    public static func monitor(
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> {
        
        AlwaysRespectfully(regions: LocationDelegate.shared, notifications: NotificationDelegate.shared)
            .monitor(predicates: predicates)
    }
}
