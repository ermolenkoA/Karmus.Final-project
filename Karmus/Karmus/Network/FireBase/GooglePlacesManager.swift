//
//  GooglePlacesManager.swift
//  Karmus
//
//  Created by VironIT on 31.08.22.
//

import Foundation
import GooglePlaces

struct Place {
    let name: String
    let identifier: String
}


final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinate
    }
    
    public func findPlaces(query: String, completion: @escaping (Swift.Result<[Place], Error>) -> ()) {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: nil
        ) { results, error in
            guard let result = results, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
            let places: [Place] = result.compactMap({
                Place(
                    name: $0.attributedFullText.string,
                    identifier: $0.placeID
                )
            })
            completion(.success(places))
        }
    }
    
    public func resolveLocation (for place: Place, completion: @escaping (Swift.Result<CLLocationCoordinate2D, Error>) -> ()){
        client.fetchPlace(
            fromPlaceID: place.identifier,
            placeFields: .coordinate,
            sessionToken: nil
        ) { mapPlace, error in
            guard let mapPlace = mapPlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinate))
                return
            }
            
            let coordinate = CLLocationCoordinate2D(
                latitude: mapPlace.coordinate.latitude,
                longitude: mapPlace.coordinate.longitude
            )
            completion(.success(coordinate))
        }
    }
}
