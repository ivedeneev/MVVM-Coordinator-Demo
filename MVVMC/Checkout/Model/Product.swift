//
//  Product.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Foundation

struct Product: Decodable, Hashable {
    let id: String
    let title: String
    let image: String
    let price: Int
    
    enum Size: String, Decodable {
        case s
        case m
        case l
        case xl
        case xxl
    }
}

struct CheckoutPosition: Decodable, Hashable {
    let id: String
    let product: Product
    let count: Int
    let size: Product.Size
}

struct CheckoutModel: Decodable, Hashable {
    let positions: [CheckoutPosition]
    let delivery: DeliveryMethod
    let paymentMethod: PaymentPethod
    let name: String?
    let phone: String?
    
}

struct City: Hashable, Decodable {
    let id = UUID().uuidString
    let title: String
}

let allCities = [City(title: "Москва"),
                 City(title: "Санкт-Петербург"),
                 City(title: "Казань"),
                 City(title: "Тамбов"),
                 City(title: "Саратов")]


struct Street: Hashable, Decodable {
    let id = UUID().uuidString
    let title: String
}

let allStreets = [Street(title: "Советская"),
                 Street(title: "Новощукинская"),
                 Street(title: "Петровка"),
                 Street(title: "Рылеева"),
                 Street(title: "Ленинграадское шоссе")]


struct Basket: Decodable {
    struct Delivery: Decodable {
        let type: DeliveryMethod
    }
    
    struct PersonalData: Decodable {
        let name: String
        let phone: String
    }
    
    let personal: PersonalData
    let id = UUID().uuidString
    let positions: [CheckoutPosition]
    
    let selectedAddress: String?
    let selectedCity: City?
    let selectedStreet: Street?
    let home: String?
    let flat: String?
}

struct Discount: Decodable {
    let id = UUID().uuidString
    let value: Int
}
