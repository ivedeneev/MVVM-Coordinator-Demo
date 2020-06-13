//
//  PhotoFeedViewModel.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 4/21/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import Foundation
import Combine

protocol PhotoFeedViewModelProtocol {
    // Input
    var createAlbumSubscriber: AnySubscriber<Void, Never> { get }
    // Output
    var showPhoto: AnyPublisher<Photo, Never> { get }
    var showAlbum: AnyPublisher<Photo, Never> { get }
    var showAllAlbums: AnyPublisher<Void, Never> { get }
    var createAlbum: AnyPublisher<Void, Never> { get }
}

final class PhotoFeedViewModel: PhotoFeedViewModelProtocol {
    var createAlbumSubscriber: AnySubscriber<Void, Never>
    
    var showPhoto: AnyPublisher<Photo, Never>
    var showAlbum: AnyPublisher<Photo, Never> = .empty()
    var showAllAlbums: AnyPublisher<Void, Never> = .empty()
    var createAlbum: AnyPublisher<Void, Never>
    
    init() {
        let _selectPhotoSubject = PassthroughSubject<Photo, Never>()
        showPhoto = _selectPhotoSubject.eraseToAnyPublisher()
        
        let _createAlbumSubject = PassthroughSubject<Void, Never>()
        createAlbumSubscriber = AnySubscriber(_createAlbumSubject)
        createAlbum = _createAlbumSubject.eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}


struct Photo {
    let id = UUID().uuidString
}

struct Album {
    let id = UUID().uuidString
    let title: String
}
