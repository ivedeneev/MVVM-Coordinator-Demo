//
//  PhotoFeedController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 4/21/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

final class PhotoFeedController: UIViewController {
    var viewModel: PhotoFeedViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        title = "Photos"
        
        let passthroughSubject = PassthroughSubject<Int, Never>()
        let anySubscriber = AnySubscriber(passthroughSubject)
        let newSubscriber = passthroughSubject
                    .sink(receiveCompletion: { completion in
                         print(completion)
                     }) { value in
                         print(value)
                     }
        let publisher = [1, 2, 3, 4].publisher
        publisher.receive(subscriber: anySubscriber)
        
        
    }
}
