//
//  MapViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.
//
//import CoreLocation
import Firebase
import KeychainSwift
import MapKit
import UIKit

class MapViewController: UIViewController{
    
    @IBOutlet weak var tasksTitle: UILabel!
    @IBOutlet weak var tasksView: UIView!
    @IBOutlet weak var taskBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titlePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var attention: UILabel!
    
    
    private var state: State = .closed
    private var viewOffset: CGFloat = 130
    private var newViewOffset: CGFloat = 0
    private var runningAnimators: [UIViewPropertyAnimator] = []
    
    private var tasksMap = [ModelTasksMap]()
    private var activeTasksMap = [ModelActiveTasksMap]()
    private var groupTasksMap = [ModelGroupTasksMap]()
    
    private var refActiveTasksMap: DatabaseReference!
    private var refTasksMap: DatabaseReference!
    private var refGroupActiveTasks: DatabaseReference!
    private var uniqueKey: String?
    private var profileId: String?
    
    private var authorizationStatus: CLAuthorizationStatus?
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D!
    
    var taskLocation: CLLocationCoordinate2D!
    var activeTaskLocation: CLLocationCoordinate2D!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        
        uploadActiveTasksInMap()
        uploadGroupTasksInMap()
        uploadTasksInMap()
        
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadRegion),
                                               name: NSNotification.Name("lol"),
                                               object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        checkLocationEnabled()
        refActiveTasksMap = Database.database().reference().child("ActiveTasks")
        refTasksMap = Database.database().reference().child("Tasks")
        refGroupActiveTasks = Database.database().reference().child("GroupTasks")
        
        uploadActiveTasksInMap()
        uploadGroupTasksInMap()
        uploadTasksInMap()
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskBottomConstraint.constant = 0
        titlePositionConstraint.constant = 8
        tasksView.layer.cornerRadius = 0
        
        Database.database().reference()
            .child(FBDefaultKeys.profilesInfo)
            .child(KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)!)
            .child("ProcessingTasks").observe( .value) { [weak self] snapshot in
                
            if snapshot.exists() {
                self?.attention.isHidden = false
            } else {
                self?.attention.isHidden = true
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        Database.database().reference()
            .child(FBDefaultKeys.profilesInfo)
            .child(KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)!)
            .child("ProcessingTasks").removeAllObservers()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        refActiveTasksMap = nil
        refTasksMap = nil
        refGroupActiveTasks = nil
    }
    
    @objc private func reloadRegion() {
        
        mapView.setRegion(MKCoordinateRegion.init(center: taskLocation, latitudinalMeters: 1500, longitudinalMeters: 1500), animated: true)
        
    }
    
    @IBAction func tapToComplitedTasks(_ sender: Any) {
        
        performSegue(withIdentifier: References.fromMapToComplitedTasksScreen, sender: self)
        
    }
    
    
    func uploadTasksInMap(){
        
        profileId = KeychainSwift.shared.get(ConstantKeys.currentProfile)
        
        refTasksMap = Database.database().reference().child("Profiles").child(profileId!).child("Tasks")
        self.mapView.removeAnnotations(mapView.annotations)
    
        refTasksMap.observe(.value, with:{ [weak self] (snapshot) in
            self?.tasksMap.removeAll()
            
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                
                let taskObject = tasks.value as? [String: AnyObject]
                let taskAddress = taskObject?["address"]
                let taskName = taskObject?["taskName"]
                let taskType = taskObject?["taskType"]
                let taskId = tasks.key
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelTasksMap(coordinate: CLLocationCoordinate2D(latitude: taskLatitudeCoordinate as! Double,
                                                                            longitude: taskLongitudeCoordinate as! Double
                                                                           ),
                                         name: taskName as! String,
                                         id: taskId,
                                         address: taskAddress as! String,
                                         type: taskType as! String)
                
                self?.tasksMap.append(task)
            }
            
            self?.mapView.didMoveToWindow()
            
            for user in self!.tasksMap{
                self?.mapView.addAnnotation(user)
            }
        })
    }
    
    func uploadActiveTasksInMap(){
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        refActiveTasksMap.observe(DataEventType.value, with:{ [weak self] (snapshot) in
            self?.activeTasksMap.removeAll()
            
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                
                let taskObject = tasks.value as? [String: AnyObject]
                let taskAddress = taskObject?["address"]
                let taskName = taskObject?["taskName"]
                let taskType = taskObject?["taskType"]
                let taskId = tasks.key
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelActiveTasksMap(coordinate: CLLocationCoordinate2D(latitude: taskLatitudeCoordinate as! Double,
                                                                                  longitude: taskLongitudeCoordinate as! Double
                                                                                 ),
                                               name: taskName as! String,
                                               id: taskId,
                                               address: taskAddress as! String,
                                               type: taskType as! String)
                
                self?.activeTasksMap.append(task)
            }
            
            self?.mapView.didMoveToWindow()
            
            for user in self!.activeTasksMap{
                self?.mapView.addAnnotation(user)
            }
        })
    }
    
    func uploadGroupTasksInMap(){
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        refGroupActiveTasks.observe(DataEventType.value, with:{ [weak self] (snapshot) in
            self?.groupTasksMap.removeAll()
            
            for tasks in snapshot.children.allObjects as! [DataSnapshot] {
                
                let taskObject = tasks.value as? [String: AnyObject]
                let taskAddress = taskObject?["address"]
                let taskName = taskObject?["taskName"]
                let taskType = taskObject?["taskType"]
                let taskId = tasks.key
                let taskLatitudeCoordinate = taskObject?["latitudeCoordinate"]
                let taskLongitudeCoordinate = taskObject?["longitudeCoordinate"]
                
                let task = ModelGroupTasksMap(coordinate: CLLocationCoordinate2D(latitude: taskLatitudeCoordinate as! Double,
                                                                                 longitude: taskLongitudeCoordinate as! Double
                                                                                ),
                                              name: taskName as! String,
                                              id: taskId,
                                              address: taskAddress as! String,
                                              type: taskType as! String)
                
                self?.groupTasksMap.append(task)
                
            }
            
            self?.mapView.didMoveToWindow()
            
            for user in self!.groupTasksMap{
                self?.mapView.addAnnotation(user)
            }
        })
    }
    
    @IBAction func tapToActiveTasksScreen(_ sender: Any) {
        
        performSegue(withIdentifier: References.fromMapToActiveTasksScreen, sender: self)
    }
    
    @IBAction func tapToTasksScreen(_ sender: Any) {
        
        performSegue(withIdentifier: References.fromMapToTasksScreen, sender: self)
    }
    
    @IBAction func tapToCreationScreen(_ sender: Any) {
        
        performSegue(withIdentifier: References.fromMapToCreationTaskScreen, sender: self)
    }
    
    func animateView(to state: State, duration: TimeInterval) {
        
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
            
            switch state {
            case .open:
                self.titlePositionConstraint.constant = self.tasksView.layer.position.x - self.tasksTitle.frame.width/2
                self.tasksTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .closed:
                self.titlePositionConstraint.constant = 8
            }
            
            self.view.layoutIfNeeded()
        }
        
        runningAnimators.append(basicAnimator)
    }
    
    func animateIfNeeded(to state: State, duration: TimeInterval) {
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
            }
            
            self.view.layoutIfNeeded()
        }
        
        runningAnimators.append(basicAnimator)
    }
    
    func setupViews(){
        
        self.taskBottomConstraint.constant = 0
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
    
    @IBAction func closeTasksView(_ sender: Any) {
        
        let newPanGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        self.mapView.addGestureRecognizer(newPanGesture)
        
    }
    
    private func checkLocationEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager = CLLocationManager()
            setupManager()
            checkAutorization()
            
        }else{
            showAlertLocation(title: "У вас выключена служба геолокации",
                              massage: "Хотите включить?",
                              url: URL(string: "App-prefs:root=Privacy&path=LOCATION"))
        }
    }
    
    private func setupManager(){

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    private func checkAutorization(){
        
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showAlertLocation(title: "Не включино местоположение",
                              massage: "Хотите это изменить?",
                              url: URL(string: UIApplication.openSettingsURLString))
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .authorized:
            break
        default:
            print("success")
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
        mapView.reloadInputViews()
        if currentLocation == nil {
            if taskLocation != nil {
                let region = MKCoordinateRegion.init(center: taskLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
                taskLocation = latestLocation.coordinate
                print("mapviewc task coordinate")
            } else {
                let region = MKCoordinateRegion.init(center: latestLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
                mapView.setRegion(region, animated: true)
                print("mapview")
            }
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

        func setAnnotation(marker: MKAnnotation, color: UIColor) -> MKMarkerAnnotationView {
            var viewMarker: MKMarkerAnnotationView
            let idView = "marker"
            viewMarker = MKMarkerAnnotationView(annotation: marker, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x: 0, y: 9)
            viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            viewMarker.markerTintColor = color
//            if color == .green {
//                viewMarker.superview?.bringSubviewToFront(viewMarker)
//            }
            return viewMarker
        }

        if let annotation = annotation as? ModelTasksMap {
            return setAnnotation(marker: annotation, color: .green)

        } else if let annotation = annotation as? ModelActiveTasksMap{
            return setAnnotation(marker: annotation, color: .red)

        } else if let annotation = annotation as? ModelGroupTasksMap {
            return  setAnnotation(marker: annotation, color: .systemBlue)

        }else{
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        for route in mapView.overlays {
            self.mapView.removeOverlay(route.self)
        }
        if let userTask = view.annotation as? ModelTasksMap {
            uniqueKey = userTask.id
            
            let alertController = UIAlertController(title: "Задание", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "Перейти к условию задания?", style: .default)
            { [unowned self] _ in
                performSegue(withIdentifier: References.fromMapTaskToConditionTaskScreen, sender: self)
                if let controller = navigationController?.topViewController as? ConditionTaskViewController {
                    controller.uniqueKeyFromMapAndTasks = uniqueKey
                }
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
            
        }else if let userTask = view.annotation as? ModelActiveTasksMap{
            
            uniqueKey = userTask.id
            
            let alertController = UIAlertController(title: "Задание", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "Перейти к условию задания?", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
                if let controller = navigationController?.topViewController as? DeclarationOfTasksViewController {
                    controller.uniqueKeyFromMap = uniqueKey
                }
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
            
        } else {
            let userTask = view.annotation as? ModelGroupTasksMap
            uniqueKey = userTask!.id
            
            let alertController = UIAlertController(title: "Задание", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "Перейти к условию задания?", style: .default)
            { [unowned self] _ in
                performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
                if let controller = navigationController?.topViewController as? DeclarationOfTasksViewController {
                    controller.uniqueKeyFromMap = uniqueKey
                }
            }
            let actionDirection = UIAlertAction(title: "Проложить маршрут?", style: .default){ _ in
                let startPointUser = MKPlacemark(coordinate: coordinate)
                let request = MKDirections.Request()
                
                request.source = MKMapItem(placemark: startPointUser)
                
                let endPointActiveTask = MKPlacemark(coordinate: userTask!.coordinate)
                
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
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
}


