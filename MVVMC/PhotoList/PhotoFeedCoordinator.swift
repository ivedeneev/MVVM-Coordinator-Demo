//
//  PhotoFeedCoordinator.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 4/21/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine

final class PhotoFeedCoordinator: BaseCoordinator<Void> {
    
    private var photoVc: PhotoFeedController

    init(photoVc: PhotoFeedController) {
        self.photoVc = photoVc
        super.init()
        rootViewController = UINavigationController(rootViewController: photoVc)
    }
    
    override func start() -> AnyPublisher<Void, Never> {
        let vm: PhotoFeedViewModelProtocol = PhotoFeedViewModel()
        photoVc.viewModel = vm
        
//        vm.createAlbum.flatMap
        
        
        return .empty()
    }
}
