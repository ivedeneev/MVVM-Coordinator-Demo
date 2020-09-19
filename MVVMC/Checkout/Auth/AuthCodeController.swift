//
//  AuthCodeController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 9/19/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine
import SnapKit

final class AuthCodeController: UIViewController {
    
    lazy var proceed = _proceedSubject
    private let _proceedSubject = PassthroughSubject<Void, Never>()
    var cancellable: Cancellable?
    var buttonTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        let button = UIButton(type: .system)
         let loader = UIActivityIndicatorView()
        button.setTitle("Ввести код", for: .normal)
        cancellable = button.publisher(for: .touchUpInside)
            .handleEvents(receiveOutput: { _ in
                button.isHidden = true
                loader.startAnimating()
            })
            .delay(for: 0.25, scheduler: DispatchQueue.main)
            .map { _ in () }
            .subscribe(_proceedSubject)
        
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        view.addSubview(loader)
        loader.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
         navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(cancel))
    }
        
    @objc func cancel() {
        (navigationController as? ModalNavigationController)?.close()
    }
}
