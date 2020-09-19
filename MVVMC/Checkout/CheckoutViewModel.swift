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

final class CheckoutViewModel: CheckoutViewModelProtocol {
    
    var showShopMap: AnySubscriber<Void, Never>
    var selectAddress: AnyPublisher<Void, Never>
    var showActions: AnyPublisher<String, Never>
    var showCities: AnyPublisher<Void, Never>
    var showStreets: AnyPublisher<City?, Never>
    
    var selectProduct: AnySubscriber<String, Never>
    var showProduct: AnyPublisher<String, Never>
    var selectDiscount: AnyPublisher<Void, Never>
    
    @Published private(set) var positions = Array<CheckoutPosition>()
    
    @Published private var basket: Basket?
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
    private let _showProductSubject = PassthroughSubject<String, Never>()
    private let _selectDiscountSubject = PassthroughSubject<Void, Never>()
    
    init() {
        selectAddress = _selectAddressSubject.eraseToAnyPublisher()
        showActions = _showActions.eraseToAnyPublisher()
        showCities = _showCitiesSubject.eraseToAnyPublisher()
        
        showShopMap = AnySubscriber(_selectAddressSubject)
        showStreets = _showStreetsSubject.eraseToAnyPublisher()
        
        
        let position1 = CheckoutPosition(
            id: "1",
            product: Product(id: "1", title: "Платье розовое", image: "https://sun1-24.userapi.com/jbYWyhP1JfU_q9c2sewgFsMrmn6_nMYxpC4Cww/LPfEvALAHxM.jpg", price: 4289),
            count: 1,
            size: .xl
        )
        
        let position2 = CheckoutPosition(
            id: "2",
            product: Product(id: "2", title: "Шуба опасная", image: "https://sun1-14.userapi.com/c856036/v856036867/23ceef/EPJDNyoDam0.jpg", price: 299),
            count: 1,
            size: .xl
        )
        
        let position3 = CheckoutPosition(
            id: "3",
            product: Product(id: "3", title: "Платье олдскул HFH", image: "https://sun1-14.userapi.com/c858024/v858024867/20ce0c/1P06GLqetzc.jpg", price: 11999),
            count: 1,
            size: .xl
        )
        
        positions = [position1, position2, position3]
        
      
        selectProduct = AnySubscriber(_showProductSubject)
        showProduct = _showProductSubject.eraseToAnyPublisher()
        
        selectDiscount = _selectDiscountSubject.eraseToAnyPublisher()
    }
    
//    func showShopMap() {
//        _selectAddressSubject.send(())
//    }
    
    func showCitiesSelect() {
        _showCitiesSubject.send()
    }
    
    func showActions(for productId: String) {
        _showActions.send(productId)
    }
    
    func showStreetsSelect() {
        _showStreetsSubject.send(selectedCity)
    }
    
    func selectPosition(at index: Int) {
        _showProductSubject.send(positions[index].id)
    }
    
    func showSelectDiscount() {
        _selectDiscountSubject.send()
    }
    
    func changeCount(for positionId: String, count: Int) -> AnyPublisher<CheckoutPosition, Never> {
        return .empty()
    }

}


final class CheckoutService {
    
    func changeCount(for productId: String, count: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { (promise) in
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
