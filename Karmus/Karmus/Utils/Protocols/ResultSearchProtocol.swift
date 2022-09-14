//
//  ResultSearchProtocol.swift
//  Karmus
//
//  Created by VironIT on 9/14/22.
//

import UIKit

protocol ResultsMapViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D)
}

protocol SetDelegate {
    func setDelegate(sender: UIViewController)
}

protocol GetAddress: AnyObject {
    func resultAddress(address: String)
}
