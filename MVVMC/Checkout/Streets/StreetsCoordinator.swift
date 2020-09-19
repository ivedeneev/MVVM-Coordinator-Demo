//
//  StreetsCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

enum StreetsCoordinationResult {
    case street(Street)
    case cancel
}

//MARK:- CitiesCoordinator
final class StreetsCoordinator: BaseCoordinator<Street?> {
    
    let city: City
    
    init(city: City) {
        self.city = city
    }
    
    override func start() -> AnyPublisher<Street?, Never> {
        let vc = StreetsViewController()
        let nc = ModalNavigationController(rootViewController: vc)
        let viewModel = StreetsViewModel()
        vc.viewModel = viewModel
        let dismiss = nc.didDismissManually.map { StreetsCoordinationResult.cancel }
        
        rootViewController?.present(nc, animated: true, completion: nil)
        
        return viewModel.selectStreet.map { StreetsCoordinationResult.street($0) }
            .merge(with: dismiss)
            .prefix(1)
            .map { result -> Street? in
                switch result {
                case .street(let street):
                    return street
                case .cancel:
                    return nil
                }
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.rootViewController?.dismiss(animated: true, completion: nil)
            })
            .eraseToAnyPublisher()
    }
}

