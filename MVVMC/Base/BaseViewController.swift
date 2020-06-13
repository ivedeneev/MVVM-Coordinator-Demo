//
//  BaseViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine


class NavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {
    
    lazy var didDismiss = _didDismiss.eraseToAnyPublisher()
    private let _didDismiss = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        _didDismiss.send()
    }
}
