//
//  BaseViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine


class ModalNavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {
    
    lazy var didDismissManually = _dismissMaually.eraseToAnyPublisher()
    private let _dismissMaually = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        _dismissMaually.send()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: { [unowned self] in
            self._dismissMaually.send()
            self._dismissMaually.send(completion: .finished)
        })
    }
}
