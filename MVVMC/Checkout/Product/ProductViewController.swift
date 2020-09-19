//
//  ProductViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 9/19/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

class ProductViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

enum ProductFlowResult {
    case test
}

enum Deeplink {
    case product(String)
}

final class ProductCoordinator: BaseCoordinator<ProductFlowResult> {
    
    var navigationController: UINavigationController?
    
    init(_ nc: UINavigationController?, productId: String, deeplink: Deeplink?) {
        self.navigationController = nc
    }
    
    override func start() -> AnyPublisher<ProductFlowResult, Never> {
        let vc = ProductViewController()
        navigationController?.pushViewController(vc, animated: true)
        return Just(.test).eraseToAnyPublisher()
    }
}
