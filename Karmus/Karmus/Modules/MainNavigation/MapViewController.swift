//
//  MapViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.
//
import CoreLocation
import Firebase
import MapKit
import UIKit

enum State {
    case closed
    case open
    
    var opposite: State {
        return self == .open ? .closed : .open
    }
}

class ModelTasksMap: NSObject, MKAnnotation{
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var id: String?
    var title: String?{
        return name
    }

    init(coordinate: CLLocationCoordinate2D, name: String, id: String){
        self.coordinate = coordinate
        self.name = name
        self.id = id
    }
}
class ModelActiveTasksMap: NSObject, MKAnnotation{
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var id: String?
    var title: String?{
        return name
    }

    init(coordinate: CLLocationCoordinate2D, name: String, id: String){
        self.coordinate = coordinate
        self.name = name
        self.id = id
    }
}

//class User: NSObject, MKAnnotation{
//    var name: String?
//    var coordinate: CLLocationCoordinate2D
//    var title: String?{
//        return "Задание"
//    }
//
//    init(coordinate: CLLocationCoordinate2D, name: String){
//        self.coordinate = coordinate
//        self.name = name
//    }
//}

//    class ModelUser{
//        var users = [User]()
//        init() {
//            setup()
//        }
//        func setup(){
//            let us1 = User(coordinate: CLLocationCoordinate2D(latitude: 53.939902, longitude: 27.566229),name: "Покормить котиков",)
//            let us2 = User(coordinate: CLLocationCoordinate2D(latitude: 53.959902, longitude: 27.546229), name: "Очистить территорию")
//            users.append(us1)
//            users.append(us2)
//        }
//    }
    

class MapViewController: UIViewController{
   
    
    @IBOutlet weak var tasksTitle: UILabel!
    @IBOutlet weak var tasksView: UIView!
    @IBOutlet weak var taskBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titlePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTasks: UIImageView!
    
    var state: State = .closed
    var viewOffset: CGFloat = 130
    var newViewOffset: CGFloat = 0
    var runningAnimators: [UIViewPropertyAnimator] = []
    
    
//    let modelUser = ModelUser()
    var tasksMap = [ModelTasksMap]()
    var activeTasksMap = [ModelActiveTasksMap]()
    var refActiveTasksMap: DatabaseReference!
    var refTasksMap: DatabaseReference!
    var uniqueKey: String?
    
    
    @IBOutlet private weak var mapView: MKMapView!
    
    private var authorizationStatus: CLAuthorizationStatus?

    private var locationManager = CLLocationManager()

    private var currentLocation: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationEnabled()
//        for user in modelUser.users{
        
        setupViews()
        refActiveTasksMap = Database.database().reference().child("ActiveTasks")
        refTasksMap = Database.database().reference().child("Tasks")
        uploadActiveTasksInMap()
        uploadTasksInMap()
    }
    func uploadActiveTasksInMap(){
        refTasksMap.observe(DataEventType.value, with:{(snapshot) in
        if snapshot.childrenCount > 0 {
            self.tasksMap.removeAll()
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                let taskObject = tasks.value as? [String: AnyObject]
                
                let taskName = taskObject?["taskName"]
                let taskId = tasks.key
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelTasksMap(coordinate: CLLocationCoordinate2D(latitude: taskLatitudeCoordinate as! Double, longitude: taskLongitudeCoordinate as! Double), name: taskName as! String, id: taskId)
                self.tasksMap.append(task)
            }
            self.mapView.didMoveToWindow()
            for user in self.tasksMap{
                self.mapView.addAnnotation(user)
            }
        }
    })
        
    }
    func uploadTasksInMap(){
        refActiveTasksMap.observe(DataEventType.value, with:{(snapshot) in
        if snapshot.childrenCount > 0 {
            self.activeTasksMap.removeAll()
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                let taskObject = tasks.value as? [String: AnyObject]
                
                let taskName = taskObject?["taskName"]
                let taskId = tasks.key
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelActiveTasksMap(coordinate: CLLocationCoordinate2D(latitude: taskLatitudeCoordinate as! Double, longitude: taskLongitudeCoordinate as! Double), name: taskName as! String, id: taskId)
                self.activeTasksMap.append(task)
            }
            self.mapView.didMoveToWindow()
            for user in self.activeTasksMap{
                self.mapView.addAnnotation(user)
            }
        }
    })
        
    }
    
    
    
    @IBAction func didTapImageView(_ sender: UITapGestureRecognizer) {

        performSegue(withIdentifier: References.fromMapToTasksScreen, sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    ///
    
    func animateView(to state: State, duration: TimeInterval) {
        
//        guard runningAnimators.isEmpty else {return}
        
        let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: nil)
        
        basicAnimator.addAnimations {
            switch state {
            case .open:
                self.taskBottomConstraint.constant = self.viewOffset
                self.tasksView.layer.cornerRadius = 20
            case .closed:
                self.taskBottomConstraint.constant = 0
                self.tasksView.layer.cornerRadius = 0
            }
            self.view.layoutIfNeeded()
        }
        basicAnimator.addAnimations {
            switch state{
            case .open:
                self.titlePositionConstraint.constant = self.tasksView.layer.position.x - self.tasksTitle.frame.width/2
                self.tasksTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .closed:
                self.titlePositionConstraint.constant = 8
               // self.tasksTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            self.view.layoutIfNeeded()
    }
        runningAnimators.append(basicAnimator)
}
    func animateIfNeeded(to state: State, duration: TimeInterval) {
        
//        guard runningAnimators.isEmpty else {return}
        
        let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: nil)
        
        basicAnimator.addAnimations {
            switch state.opposite {
            case .open:
                self.taskBottomConstraint.constant = self.viewOffset
                self.tasksView.layer.cornerRadius = 20
            case .closed:
                self.taskBottomConstraint.constant = 0
                self.tasksView.layer.cornerRadius = 0
            }
            self.view.layoutIfNeeded()
        }
        basicAnimator.addAnimations {
            switch state.opposite{
            case .open:
                self.titlePositionConstraint.constant = self.tasksView.layer.position.x - self.tasksTitle.frame.width/2
                self.tasksTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .closed:
                self.titlePositionConstraint.constant = 8
               // self.tasksTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            self.view.layoutIfNeeded()
    }
        runningAnimators.append(basicAnimator)
}
    
    func setupViews(){
        self.taskBottomConstraint.constant = 0
      //  self.tasksTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.view.layoutIfNeeded()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onDrag(_:)))
        let newPanGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        
        self.tasksView.addGestureRecognizer(panGesture)
        self.tasksView.addGestureRecognizer(newPanGesture)
        
        self.tasksView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.tasksView.layer.shadowColor = UIColor.black.cgColor
        self.tasksView.layer.shadowOpacity = 1
        self.tasksView.layer.shadowRadius = 3
    }
    
    @objc func onDrag(_ gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            animateView(to: state.opposite, duration: 0.4)
        case .changed:
            let translation = gesture.translation(in: tasksView)
            let fraction = abs(translation.y / viewOffset)
            runningAnimators.forEach{ (animator) in
                animator.fractionComplete = fraction
            }
        case .ended:
            runningAnimators.forEach{ $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)}
        default:
            break
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        animateIfNeeded(to: state.opposite, duration: 0.4)
        runningAnimators.forEach { $0.startAnimation() }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == References.fromMapActiveTaskToDeclarationTaskScreen {
            let controller = segue.destination as! DeclarationOfTasksViewController
             print(uniqueKey)
             controller.uniqueKeyFromMap = uniqueKey
             
        }
    }
}

//extension MapViewController: UISearchBarDelegate{
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBarController.resignFirstResponder()
//
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(searchBarController.text!){ (placemarks:[CLPlacemark]?, error:Error?) in
//            if error == nil {
//                let placemark = placemarks?.first
//
//                let anno = MKPointAnnotation()
//                anno.coordinate = (placemark?.location?.coordinate)!
//                anno.title = self.searchBarController.text!
//                
//                self.mapView.addAnnotation(anno)
//                self.mapView.selectAnnotation(anno, animated: true)
//            }else {
//                print(error?.localizedDescription ?? "error")
//            }
//        }
//    }
//}

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
//        guard let annotation = annotation as? ModelTasksMap else {return nil}
        var viewMarker: MKMarkerAnnotationView
        let idView = "marker"
        if let annotation = annotation as? ModelTasksMap {
            viewMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x: 0, y: 9)
        viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            viewMarker.markerTintColor = .green
            
        } else if let annotation = annotation as? ModelActiveTasksMap{
            
            viewMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x: 0, y: 9)
        viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            viewMarker.markerTintColor = .red
            
        } else {
            return nil
        }
 //       if let view = mapView.dequeueReusableAnnotationView(withIdentifier: idView) as? MKMarkerAnnotationView{
//            view.annotation = annotation
//            viewMarker = view
//        }else{
//            if refTasksMap.isProxy(){
//                viewMarker.markerTintColor = .green
//            }else{
//        viewMarker.markerTintColor = .red
//            }
//        viewMarker.leftCalloutAccessoryView = UILabel(frame: )
       // }
        return viewMarker

    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        for route in mapView.overlays {
            self.mapView.removeOverlay(route.self)
        }
        
        if let userTask = view.annotation as? ModelTasksMap {
            
            let alertController = UIAlertController(title: "Задание", message: "", preferredStyle: .alert)
        let actionTask = UIAlertAction(title: "Перейти к условию задания?", style: .default)
        { [unowned self] _ in
            performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
        }
            let actionDirection = UIAlertAction(title: "Проложить маршрут?", style: .default){  _ in
                let startPointUser = MKPlacemark(coordinate: coordinate)
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: startPointUser)
                let endPointTask = MKPlacemark(coordinate: userTask.coordinate)
                request.destination = MKMapItem(placemark: endPointTask)
                request.transportType = .any

                let direction = MKDirections(request: request)
                direction.calculate{ (response, error) in
                    guard let response = response else { return }
                    for route in response.routes {
                        mapView.addOverlay(route.polyline)
            }
                }
            }
               let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
               alertController.addAction(actionTask)
               alertController.addAction(actionDirection)
               alertController.addAction(actionCancel)
               self.present(alertController, animated: true)
//

        }else
            if let userTask = view.annotation as? ModelActiveTasksMap{
            uniqueKey = userTask.id
            print("Уникальный ключ " + uniqueKey!)
            let alertController = UIAlertController(title: "Задание", message: "", preferredStyle: .alert)
        let actionTask = UIAlertAction(title: "Перейти к условию задания?", style: .default)
        { [unowned self] _ in
            performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
        }
            let actionDirection = UIAlertAction(title: "Проложить маршрут?", style: .default){ _ in
                let startPointUser = MKPlacemark(coordinate: coordinate)
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: startPointUser)
                let endPointActiveTask = MKPlacemark(coordinate: userTask.coordinate)
                request.destination = MKMapItem(placemark: endPointActiveTask)
                request.transportType = .any
                let direction = MKDirections(request: request)
                direction.calculate{ (response, error) in
                    guard let response = response else { return }
                    for route in response.routes {
                        mapView.addOverlay(route.polyline)
            }
                }
            }
        
               let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
               alertController.addAction(actionTask)
               alertController.addAction(actionDirection)
               alertController.addAction(actionCancel)
               self.present(alertController, animated: true)
        }else{
            print("eee[[[[[")
//            request.destination = MKMapItem(placemark: startPointUser)
        }

//        let userTask = view.annotation as! ModelTasksMap
//        let startPointUser = MKPlacemark(coordinate: coordinate)
//        let endPointTask = MKPlacemark(coordinate: userTask.coordinate)
//        request.source = MKMapItem(placemark: startPointUser)
//        request.destination = MKMapItem(placemark: endPointTask)
//        request.requestsAlternateRoutes = true
       
    }
  
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
}
