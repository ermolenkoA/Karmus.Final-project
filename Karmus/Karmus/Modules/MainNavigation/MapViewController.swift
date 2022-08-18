//
//  MapViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.
//
import CoreLocation
import MapKit
import UIKit

class User: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?{
        return "eee"
    }

    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

    class ModelUser{
        var users = [User]()
        init() {
            setup()
        }
        func setup(){
            let us1 = User(coordinate: CLLocationCoordinate2D(latitude: 53.939902, longitude: 27.566229))
            let us2 = User(coordinate: CLLocationCoordinate2D(latitude: 53.959902, longitude: 27.546229))
            users.append(us1)
            users.append(us2)
        }
    }
    

class MapViewController: UIViewController{
   
    let modelUser = ModelUser()
    
    @IBOutlet private weak var mapView: MKMapView!
    
    private var authorizationStatus: CLAuthorizationStatus?

    private var locationManager = CLLocationManager()

    private var currentLocation: CLLocationCoordinate2D!

    //    private var region: MKCoordinateRegion! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        checkLocationEnabled()
        for user in modelUser.users{
            mapView.addAnnotation(user)
        }
//        locationManager.requestAlwaysAuthorization()
     
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func checkLocationEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
//            locationManager.delegate = self
            setupManager()
            checkAutorization()
            print("enabled")
        }else{
            showAlertLocation(title: "У вас выключена служба геолокации", massage: "Хотите включить?", url: URL(string: "App-prefs:root=Privacy&path=LOCATION"))
        }
    }

    private func setupManager(){
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    private func checkAutorization(){
//        guard let locationManager = locationManager else {return}
        locationManager.delegate = self
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("authrizat")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("denied")
            showAlertLocation(title: "Не включино местоположение", massage: "Хотите это изменить?", url: URL(string: UIApplication.openSettingsURLString))
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            print("always")
//            break
        case .authorizedWhenInUse:
            print("show")
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
//            locationManager.requestLocation()
 //           break
        case .authorized:
            print("nonautho")
            break
        default:
            print("def")
        }
    }
    private func showAlertLocation(title: String, massage: String?, url: URL?){
        let alert = UIAlertController(title: title.self, message: massage.self, preferredStyle: .alert)

        let settings = UIAlertAction(title: "Настройки", style: .default){
            alert in
            if let url = url.self{
                UIApplication.shared.open(url, options: [:])
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)

        alert.addAction(settings)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
        
    }

}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last?.coordinate else {return}
        guard let latestLocation = locations.first else {return}
        if currentLocation == nil {
            let region = MKCoordinateRegion.init(center: latestLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
            print("mapview")
        }
        currentLocation = latestLocation.coordinate
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAutorization()
        print("checkAUr")
    }
}
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? User else {return nil}
        var viewMarker: MKAnnotationView
        let idView = "marker"
//        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: idView) as? MKMarkerAnnotationView{
//            view.annotation = annotation
//            viewMarker = view
//        }else{
            viewMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x: 0, y: 9)
        viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
       // }
        return viewMarker

    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        for route in mapView.overlays {
            self.mapView.removeOverlay(route.self)
        }
        let user = view.annotation as! User
        let startPoint = MKPlacemark(coordinate: coordinate)
        let endPoint = MKPlacemark(coordinate: user.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPoint)
        request.destination = MKMapItem(placemark: endPoint)
        request.transportType = .any
        
        let direction = MKDirections(request: request)
        direction.calculate{ (response, error) in
            guard let response = response else { return }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
}
