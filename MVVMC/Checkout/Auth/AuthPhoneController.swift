//
//  AuthController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 9/19/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine
import SnapKit

final class AuthPhoneController: UIViewController {
    // pass phone to next controller
    lazy var proceed = _proceedSubject//.prefix(1)
    private let _proceedSubject = PassthroughSubject<String, Never>()
    var cancellable: Cancellable?
    let loader = UIActivityIndicatorView()
    let button = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Авторизация"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        button.setTitle("Ввести номер телефона", for: .normal)
        cancellable = button.publisher(for: .touchUpInside)
            .handleEvents(receiveOutput: { [loader, button] _ in
                button.isHidden = true
                loader.startAnimating()
            })
            .delay(for: 0.25, scheduler: DispatchQueue.main)
            .map { _ in "+79999999999" }
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loader.stopAnimating()
        button.isHidden = false
    }
    
    @objc func cancel() {
        (navigationController as? ModalNavigationController)?.close()
    }
}
