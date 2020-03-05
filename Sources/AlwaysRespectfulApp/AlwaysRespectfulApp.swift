//
//  AlwaysRespectfulApp.swift
//  AlwaysRespectfulApp
//
//  Created by Etienne Vautherin on 05/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import AlwaysRespectfully


public struct AlwaysRespectfulApp {
    public static func monitor<Predicate>(
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> where Predicate: Hashable, Predicate: PositionPredicate {
        AlwaysRespectfully(regions: LocationDelegate.shared, notifications: NotificationDelegate.shared)
            .monitor(predicates: predicates)
    }
}
