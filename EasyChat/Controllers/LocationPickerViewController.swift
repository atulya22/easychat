//
//  LocationPickerViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/9/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {

    private var isPickable = true
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?, isPickable: Bool) {
        self.coordinates = coordinates
        self.isPickable = isPickable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title :"Send", style: .done, target: self, action: #selector(sendButtonTapped))
            map.isUserInteractionEnabled = true

            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            
            guard let coordinates = self.coordinates else {
                return
            }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(map)

    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        map.removeAnnotations(map.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
        //Drop pin on location
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
}
