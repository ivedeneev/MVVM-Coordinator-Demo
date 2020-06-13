//
//  ApplicationCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 4/11/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

final class ApplicationCoordinator: BaseCoordinator<Void> {
    
    private var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
//    private lazy var photoCoordinator = PhotoFeedCoordinator(photoVc: PhotoFeedController())
//    private lazy var checkoutCoordinator = PhotoFeedCoordinator(photoVc: Checkoutv())
   
    override func start() -> AnyPublisher<Void, Never> {
        return TabbarCoordinator(window: window).start()
    }
}

final class TabbarCoordinator: BaseCoordinator<Void> {
    private var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        let tabbarViewController = UITabBarController()
        
        let checkout = CheckoutCoordinator(nc: UINavigationController())
        let rootControllers = [checkout.rootViewController].compactMap { $0 }
        tabbarViewController.setViewControllers(rootControllers, animated: false)
        
        window?.rootViewController = tabbarViewController
        window?.makeKeyAndVisible()
        
        _ = coordinate(to: checkout).sink(receiveValue: {})
        
        
        return .empty()
    }
}
