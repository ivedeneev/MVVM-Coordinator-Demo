//
//  AuthCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 9/19/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

final class AuthCoordinator: BaseCoordinator<CommonModalFlowResult<Void>> {
    
    var root: UIViewController?
    var promt: String?
    
    init(_ rootVc: UIViewController?, promt: String? = nil) {
        root = rootVc
        self.promt = promt
    }
    
    override func start() -> AnyPublisher<CommonModalFlowResult<Void>, Never> {
        let phoneVc = AuthPhoneController()
        
        let navController = ModalNavigationController(rootViewController: phoneVc)
        phoneVc.navigationItem.prompt = promt
        root?.present(
            navController,
            animated: true,
            completion: nil
        )
        
        let authPublisher = phoneVc.proceed
            .flatMap { phone -> AnyPublisher<CommonModalFlowResult<Void>, Never> in
                let codeVc = AuthCodeController()
                codeVc.title = phone
                phoneVc.navigationController?.pushViewController(codeVc, animated: true)
                return codeVc.proceed
                    .map { _ in .value(Void()) }
                    .eraseToAnyPublisher()
            }
            .flatMap { value -> AnyPublisher<CommonModalFlowResult<Void>, Never> in
                return Future { (promise) in
                    navController.dismiss(animated: true) {
                        promise(.success(.value(())))
                    }
                }.eraseToAnyPublisher()
            }
            
        let dismissPublisher = navController.didDismissManually
            .map { _ in CommonModalFlowResult<Void>.dismiss }
        
        return authPublisher
            .merge(with: dismissPublisher)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
