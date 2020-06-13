//
//  CheckoutCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine
import CoreLocation

final class CheckoutCoordinator: BaseCoordinator<Void> {
    
    var cancellables = Set<AnyCancellable>()

    init(nc: UINavigationController) {
        super.init()
        
        rootViewController = nc
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        
        let vc = CheckoutViewController()
        vc.tabBarItem = UITabBarItem(title: "Корзина", image: .actions, selectedImage: .actions)
        let vm = CheckoutViewModel()
        vc.viewModel = vm
        
        (rootViewController as? UINavigationController)?.setViewControllers([vc], animated: false)
        
        vm.$showMap
            .dropFirst()
            .flatMap(showMap)
            .compactMap { $0.title }
            .assign(to: \.selectedAddress, on: vm)
            .store(in: &cancellables)
        
        vm.showActions
            .flatMap(showActions)
            .assign(to: \.selectedAction, on: vm)
            .store(in: &cancellables)
        
        vm.showCities
            .flatMap(showCitiesSerarch)
            .compactMap { $0 }
            .assign(to: \.selectedCity, on: vm)
            .store(in: &cancellables)
        
        vm.showStreets
            .flatMap(showStreets)
            .assign(to: \.selectedStreet, on: vm)
            .store(in: &cancellables)
        
        return .empty()
    }
    
    private func showMap() -> AnyPublisher<MapFlowResult, Never> {
        let c = MapCoordinator(sourceVc: rootViewController!)
        return coordinate(to: c)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.rootViewController?.dismiss(animated: true, completion: nil)
            }).eraseToAnyPublisher()
    }
    
    private func showCitiesSerarch() -> AnyPublisher<City?, Never> {
        let c = CitiesCoordinator()
        c.rootViewController = rootViewController
        return coordinate(to: c)
    }
    
    private func showStreets(for city: City?) -> AnyPublisher<Street?, Never> {
        guard let city = city else {
            showShouldSelectCityAlert()
            return .empty()
        }
        
        let c = StreetsCoordinator(city: city)
        c.rootViewController = rootViewController
        return coordinate(to: c)
    }
    
    private func showActions(for productId: String) -> AnyPublisher<(CheckoutPositionAction, String)?, Never> {
        return Future<CheckoutPositionAction?, Never> { (promise) in
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for action in CheckoutPositionAction.allCases {
                ac.addAction(.init(title: action.localized, style: .destructive, handler: { _ in
                    promise(.success(action))
                }))
            }
            
            ac.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: { _ in
                promise(.success(nil))
            }))
            
            self.rootViewController?.present(ac, animated: true, completion: nil)
        }
        .map {
            guard let action = $0 else { return nil }
            return (action, productId)
        }
        .eraseToAnyPublisher()
    }
    
    private func showShouldSelectCityAlert()/* -> AnyPublisher<Void, Never>*/ {
        let ac = UIAlertController(title: "Ошибка", message: "Выберите сначала город", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
        rootViewController?.present(ac, animated: true, completion: nil)
    }
}


enum CheckoutPositionAction: CaseIterable {
    case delete
    
    var localized: String {
        switch self {
        case .delete:
            return "Удалить"
        }
    }
    
    var style: UIAlertAction.Style {
        switch self {
        case .delete:
            return .destructive
        }
    }
}
