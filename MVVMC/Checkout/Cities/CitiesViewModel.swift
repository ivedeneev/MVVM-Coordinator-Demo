//
//  CitiesViewModel.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Combine


final class CitiesViewModel {
    
    @Published var cities = Array<City>()
    
    init() {
        cities = allCities
    }
    
    lazy var selectCity = _selectSubject.eraseToAnyPublisher()
    private let _selectSubject = PassthroughSubject<City, Never>()
    
    func select(at index: Int) {
        _selectSubject.send(cities[index])
    }
}
