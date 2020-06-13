//
//  StreetsViewModel.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Combine

final class StreetsViewModel {
    @Published var streets = Array<Street>()
    
    init() {
        streets = allStreets
    }
    
    lazy var selectStreet = _selectSubject.eraseToAnyPublisher()
    private let _selectSubject = PassthroughSubject<Street, Never>()
    
    func select(at index: Int) {
        _selectSubject.send(streets[index])
    }
}
