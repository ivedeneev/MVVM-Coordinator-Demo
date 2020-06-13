//
//  CitiesCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

//MARK:- CitiesCoordinator
final class CitiesCoordinator: BaseCoordinator<City?> {
    
    override func start() -> AnyPublisher<City?, Never> {
        let vc = CitiesViewController()
        let nc = NavigationController(rootViewController: vc)
        let viewModel = CitiesViewModel()
        vc.viewModel = viewModel
        let dismiss = nc.didDismiss.map { CitiesSelectResult.cancel }
        
        rootViewController?.present(nc, animated: true, completion: nil)
        
        return viewModel.selectCity.map { CitiesSelectResult.city($0) }
            .merge(with: dismiss)
            .prefix(1)
            .map { result -> City? in
                switch result {
                case .city(let city):
                    return city
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
