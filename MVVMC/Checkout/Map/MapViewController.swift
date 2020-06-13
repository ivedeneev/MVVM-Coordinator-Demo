//
//  MapViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/10/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
import Combine

final class MapCoordinator: BaseCoordinator<MapFlowResult> {
    
    init(sourceVc: UIViewController) {
        super.init()
        rootViewController = sourceVc
    }
    
    override func start() -> AnyPublisher<MapFlowResult, Never> {
        let vc = MapViewController()
        rootViewController?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
        return vc.subject
            .eraseToAnyPublisher()
    }
}

enum MapFlowResult {
    case location(CLLocation, String)
    case dismiss
    
    var location: CLLocation? {
        switch self {
        case .location(let loc, _):
            return loc
        default:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .location(_, let title):
            return title
        default:
            return nil
        }
    }

}

final class MapViewController: UIViewController, CLLocationManagerDelegate {
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    let subject = PassthroughSubject<MapFlowResult, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectLocation))
        navigationController?.setToolbarHidden(false, animated: false)
        setToolbarItems([cancel, space, done], animated: false)
        title = "Выберите адрес"
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @objc func close() {
        subject.send(.dismiss)
        subject.send(completion: .finished)
    }
    
    @objc func selectLocation() {
        guard let loc = locationManager.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc, preferredLocale: .init(identifier: "ru_RU")) { [weak self] (placemarks, error) in
            guard let mark = placemarks?.first?.name else {
                self?.subject.send(completion: .finished)
                return
            }
            
            self?.subject.send(.location(loc, mark))
            self?.subject.send(completion: .finished)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.isZoomEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let regionRadius: CLLocationDistance = 2500
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        manager.stopUpdatingLocation()
        
        let m = Marker(title: "Мое местоположение", coordinate: location.coordinate)
        mapView.addAnnotation(m)
    }
}


class Marker: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.coordinate = coordinate

    super.init()
  }

  var subtitle: String? {
    return nil
  }
}
