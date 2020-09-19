//
//  Coordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 4/11/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

protocol CoordinatorProtocol {
    var rootViewController: UIViewController? { get }
}

class BaseCoordinator<T>: CoordinatorProtocol {
       var rootViewController: UIViewController?
    
       private let identifier = UUID()

       /// Dictionary of the child coordinators. Every child coordinator should be added
       /// to that dictionary in order to keep it in memory.
       /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
       /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
       private var childCoordinators = [UUID: CoordinatorProtocol]()


       /// Stores coordinator to the `childCoordinators` dictionary.
       ///
       /// - Parameter coordinator: Child coordinator to store.
       private func store<T>(coordinator: BaseCoordinator<T>) {
           childCoordinators[coordinator.identifier] = coordinator
       }

       /// Release coordinator from the `childCoordinators` dictionary.
       ///
       /// - Parameter coordinator: Coordinator to release.
       private func free<T>(coordinator: BaseCoordinator<T>) {
        print("free coordinator: \(coordinator)")
           childCoordinators[coordinator.identifier] = nil
       }

       /// 1. Stores coordinator in a dictionary of child coordinators.
       /// 2. Calls method `start()` on that coordinator.
       /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
       ///
       /// - Parameter coordinator: Coordinator to start.
       /// - Returns: Result of `start()` method.
       func coordinate<T>(to coordinator: BaseCoordinator<T>) -> AnyPublisher<T, Never> {
           store(coordinator: coordinator)
           return coordinator.start()
                .last()
                .handleEvents(
                    receiveOutput: { [weak self] _ in
                        self?.free(coordinator: coordinator)
                    },
                    receiveCompletion: { _ in print("finish coordinator: \(coordinator)") },
                    receiveCancel: { print("cancel coordinator: \(coordinator)") })
                .eraseToAnyPublisher()
       }

       /// Starts job of the coordinator.
       ///
       /// - Returns: Result of coordinator job.
       func start() -> AnyPublisher<T, Never> {
           fatalError("Start method should be implemented.")
       }
}
