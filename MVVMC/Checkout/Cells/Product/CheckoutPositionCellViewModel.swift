//
//  ProductCellViewModel.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Combine

final class CheckoutPositionCellViewModel: Hashable {
    static func == (lhs: CheckoutPositionCellViewModel, rhs: CheckoutPositionCellViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum Action {
        case changeCount(Int)
        case showActions
    }
    
    @Published var action: Action?
    @Published var count: Int = 1
    @Published var isLoading = false
    @Published var showActions: Void = ()
    let id: String
    let title: String
    let size: String
    let price: Int
    var totalPrice: AnyPublisher<String?, Never>!
    let imageLink: String
    
    init(position: CheckoutPosition) {
        imageLink = position.product.image
        id = position.id
        title = position.product.title
        size = position.size.rawValue.uppercased()
        price = position.product.price
        totalPrice = $count.map { String($0 * position.product.price) }.eraseToAnyPublisher()
    }
}
