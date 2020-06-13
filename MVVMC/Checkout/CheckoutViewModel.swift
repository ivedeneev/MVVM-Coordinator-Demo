//
//  CheckoutViewModel.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Combine

protocol CheckoutViewModelProtocol {
//    var selectedAddress: String? { get set }
//    var selectAddress: AnyPublisher<Void, Never> { get }
//    var showActions: AnyPublisher<String, Never> { get }
//    var deliveryMethod: DeliveryMethod { get set }
//    var showCities: AnyPublisher<Void, Never> { get }
//
//    func showShopMap()
//    func showCitiesSelect()
//    func showActions(for productId: String)
}

protocol CheckoutViewModelInput {
    func selectPosition(at index: Int)
    func showActionsForPosition(at index: Int)
}

final class CheckoutViewModel: CheckoutViewModelProtocol {
    
    var showShopMap: AnySubscriber<Void, Never>
    var selectAddress: AnyPublisher<Void, Never>
    var showActions: AnyPublisher<String, Never>
    var showCities: AnyPublisher<Void, Never>
    var showStreets: AnyPublisher<City?, Never>
    
    @Published private(set) var positions = Array<CheckoutPosition>()
    @Published var name: String?
    @Published var phone: String?
    @Published var selectedAddress: String?
    @Published var selectedCity: City?
    @Published var selectedStreet: Street?
    @Published var home: String?
    @Published var flat: String?
    @Published var deliveryMethod: DeliveryMethod = .delivery
    @Published var selectedAction: (CheckoutPositionAction, String)?
    
    @Published var showMap: Void = ()
    
    private let _selectAddressSubject = PassthroughSubject<Void, Never>()
    private let _showActions = PassthroughSubject<String, Never>()
    private let _showCitiesSubject = PassthroughSubject<Void, Never>()
    private let _showStreetsSubject = PassthroughSubject<City?, Never>()
    
    init() {
        selectAddress = _selectAddressSubject.eraseToAnyPublisher()
        showActions = _showActions.eraseToAnyPublisher()
        showCities = _showCitiesSubject.eraseToAnyPublisher()
        
        showShopMap = AnySubscriber(_selectAddressSubject)
        showStreets = _showStreetsSubject.eraseToAnyPublisher()
    }
    
//    func showShopMap() {
//        _selectAddressSubject.send(())
//    }
    
    func showCitiesSelect() {
        _showCitiesSubject.send(())
    }
    
    func showActions(for productId: String) {
        _showActions.send(productId)
    }
    
    func showStreetsSelect() {
        _showStreetsSubject.send(selectedCity)
    }
    
    func selectPosition(at index: Int) {
        
    }
}
