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
        let rootControllers = [checkout.rootViewController, VC()].compactMap { $0 }
        tabbarViewController.setViewControllers(rootControllers, animated: false)
        
        window?.rootViewController = tabbarViewController
        window?.makeKeyAndVisible()
        
        _ = coordinate(to: checkout).sink(receiveValue: {})
        
        
        return .empty()
    }
}


final class VC: UIViewController {
    let stacView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stacView)
        view.backgroundColor = .systemBackground
        
        stacView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        stacView.spacing = 10
        stacView.distribution = .fillEqually
        
        let red = UIView()
        red.backgroundColor = .systemRed
        
        let blue = UIView()
        blue.backgroundColor = .systemBlue
        
        stacView.addArrangedSubview(red)
        stacView.addArrangedSubview(blue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.25) {
                red.isHidden = true
            }
        }
    }
}
