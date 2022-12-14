//
//  MapViewController.swift
//  Karmus
//
//  Created by VironIT on 17.08.22.

import Firebase
import KeychainSwift
import MapKit
import UIKit

class MapViewController: UIViewController{
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tasksTitle: UILabel!
    @IBOutlet weak var tasksView: UIView!
    @IBOutlet weak var taskBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titlePositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var attention: UILabel!
    
    // MARK: - Private Properties
    
    private var state: State = .closed
    private var viewOffset: CGFloat = 130
    private var newViewOffset: CGFloat = 0
    private var runningAnimators: [UIViewPropertyAnimator] = []
    
    private var tasksMap = [ModelTasksMap]()
    private var activeTasksMap = [ModelActiveTasksMap]()
    private var groupTasksMap = [ModelGroupTasksMap]()
    
    private var refActiveTasksMap = Database.database().reference().child("ActiveTasks")
    private var refTasksMap = Database.database().reference().child("Tasks")
    private var refGroupActiveTasks = Database.database().reference().child("GroupTasks")
    private var uniqueKey: String?
    private var profileId: String?
    
    private var authorizationStatus: CLAuthorizationStatus?
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D!
    
    // MARK: - Public Properties
    
    var taskLocation: CLLocationCoordinate2D!
    var activeTaskLocation: CLLocationCoordinate2D!
    
    // MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        mapView.delegate = self
        mapView.didMoveToWindow()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadRegion),
                                               name: NSNotification.Name("lol"),
                                               object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationEnabled()
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
    
    // MARK: - Private functions
    
    @objc private func reloadRegion() {
        mapView.setRegion(MKCoordinateRegion.init(center: taskLocation, latitudinalMeters: 1500, longitudinalMeters: 1500), animated: true)
    }
    
   
    
    private func uploadTasksInMap() {
        DataBaseManagerForMap.getTasks(tasksType: .userTasks) { [weak self] tasks in
            
            guard let self = self else { return }
            
            guard let newTasks = tasks as? [ModelTasksMap] else {
                return
            }
            
            let newTasksIds = newTasks.map { $0.id }
            let tasksIDs = self.tasksMap.map { $0.id }
            
            let tasksToRemove = self.tasksMap.filter { !newTasksIds.contains($0.id) }
            let tasksToAdd = newTasks.filter { !tasksIDs.contains($0.id) }
            self.tasksMap = newTasks
            
            self.mapView.didMoveToWindow()
            
            for task in tasksToRemove {
                self.mapView.removeAnnotation(task)
            }
            
            for task in tasksToAdd {
                self.mapView.addAnnotation(task)
            }
            
        }
    }
    
    private func uploadActiveTasksInMap() {
        
        DataBaseManagerForMap.getTasks(tasksType: .activeTasks) { [weak self] tasks in
            
            guard let self = self else { return }
            
            guard let newTasks = tasks as? [ModelActiveTasksMap] else {
                return
            }
            
            let newTasksIds = newTasks.map { $0.id }
            let tasksIDs = self.activeTasksMap.map { $0.id }
            
            let tasksToRemove = self.activeTasksMap.filter { !newTasksIds.contains($0.id) }
            let tasksToAdd = newTasks.filter { !tasksIDs.contains($0.id) }
            self.activeTasksMap = newTasks
            
            self.mapView.didMoveToWindow()
            
            for task in tasksToRemove {
                self.mapView.removeAnnotation(task)
            }
            
            for task in tasksToAdd {
                self.mapView.addAnnotation(task)
            }
            
        }
        
    }
    
    private func uploadGroupTasksInMap() {
        
        print(self.mapView.annotations.count)
        
        DataBaseManagerForMap.getTasks(tasksType: .groupTasks) { [weak self] tasks in
            
            guard let self = self else { return }
            
            guard let newTasks = tasks as? [ModelGroupTasksMap] else {
                return
            }
            
            let newTasksIDs = newTasks.map { $0.id }
            let tasksIDs = self.groupTasksMap.map { $0.id }
            
            let tasksToRemove = self.groupTasksMap.filter { !newTasksIDs.contains($0.id) }
            let tasksToAdd = newTasks.filter { !tasksIDs.contains($0.id) }
            self.groupTasksMap = newTasks
            
            self.mapView.didMoveToWindow()
            
            for task in tasksToRemove {
                self.mapView.removeAnnotation(task)
            }
            
            for task in tasksToAdd {
                self.mapView.addAnnotation(task)
            }
            
            print(self.mapView.annotations.count)
            
        }
        
    }
    
    private func showAlertLocation(title: String, massage: String?, url: URL?) {
        let alert = UIAlertController(title: title.self, message: massage.self, preferredStyle: .alert)
        let settings = UIAlertAction(title: "??????????????????", style: .default){
            alert in
            if let url = url.self{
                UIApplication.shared.open(url, options: [:])
            }
        }
        let cancelAction = UIAlertAction(title: "????????????", style: .cancel)
        alert.addAction(settings)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    private func checkLocationEnabled(){
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            setupManager()
            checkAutorization()
        }else{
            showAlertLocation(title: "?? ?????? ?????????????????? ???????????? ????????????????????",
                              massage: "???????????? ?????????????????",
                              url: URL(string: "App-prefs:root=Privacy&path=LOCATION"))
        }
    }

    private func setupManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkAutorization() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showAlertLocation(title: "???? ???????????????? ????????????????????????????",
                              massage: "???????????? ?????? ?????????????????",
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

    // MARK: - Animate pop
    
    private func animateView(to state: State, duration: TimeInterval) {
        
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
    
    private func animateIfNeeded(to state: State, duration: TimeInterval) {
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
            
            switch state.opposite {
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
    
    private func setupViews() {
        
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
    
    @objc private func onDrag(_ gesture: UIPanGestureRecognizer){
        
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
            runningAnimators.forEach{ $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        default:
            break
        }
        
    }
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        animateIfNeeded(to: state.opposite, duration: 0.4)
        runningAnimators.forEach { $0.startAnimation() }
    }
    
    // MARK: - IBAction
    
    @IBAction func tapToComplitedTasks(_ sender: Any) {
    performSegue(withIdentifier: References.fromMapToComplitedTasksScreen, sender: self)
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
    
    @IBAction func closeTasksView(_ sender: Any) {
        let newPanGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        self.mapView.addGestureRecognizer(newPanGesture)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {return}
        mapView.reloadInputViews()
        if currentLocation == nil {
            if taskLocation != nil {
                let region = MKCoordinateRegion.init(center: taskLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
                taskLocation = latestLocation.coordinate
            } else {
                let region = MKCoordinateRegion.init(center: latestLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
                mapView.setRegion(region, animated: true)
            }
        }
        currentLocation = latestLocation.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAutorization()
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        func setAnnotation(marker: MKAnnotation, color: UIColor) -> MKMarkerAnnotationView {
            var viewMarker: MKMarkerAnnotationView
            let idView = "marker"
            
            viewMarker = MKMarkerAnnotationView(annotation: marker, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x: 0, y: 9)
            viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            viewMarker.markerTintColor = color
            
            return viewMarker
        }
        
        if let annotation = annotation as? ModelTasksMap {
            return setAnnotation(marker: annotation, color: .green)
        } else if let annotation = annotation as? ModelActiveTasksMap {
            return setAnnotation(marker: annotation, color: .red)
        } else if let annotation = annotation as? ModelGroupTasksMap {
            return  setAnnotation(marker: annotation, color: .systemBlue)
        } else {
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
            
            let alertController = UIAlertController(title: "??????????????", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "?????????????? ?? ?????????????? ???????????????", style: .default)
            { [unowned self] _ in
                            
                performSegue(withIdentifier: References.fromMapTaskToConditionTaskScreen, sender: self)
                if let controller = navigationController?.topViewController as? ConditionTaskViewController {
                    controller.uniqueKeyFromMapAndTasks = uniqueKey
                }
            }
            
            let actionDirection = UIAlertAction(title: "?????????????????? ???????????????", style: .default) {  _ in
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
            
            let actionCancel = UIAlertAction(title: "????????????", style: .cancel)
            alertController.addAction(actionTask)
            alertController.addAction(actionDirection)
            alertController.addAction(actionCancel)
            self.present(alertController, animated: true)
            
        } else if let userTask = view.annotation as? ModelActiveTasksMap {
            uniqueKey = userTask.id
            
            let alertController = UIAlertController(title: "??????????????", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "?????????????? ?? ?????????????? ???????????????", style: .default) { [unowned self] _ in
                Database.database().reference().child(FBDefaultKeys.activeTasks).child(uniqueKey!).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                        if snapshot.exists() {
                            self?.performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
                            if let controller = self?.navigationController?.topViewController as? DeclarationOfTasksViewController {
                                controller.uniqueKeyFromMap = self?.uniqueKey
                            }
                        } else {
                    showAlert("????????????", "?????????????? ?????? ???? ????????????????????", where: self)
                        }
                    }
                )
            }
            
            let actionDirection = UIAlertAction(title: "?????????????????? ???????????????", style: .default) { _ in
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
            
            let actionCancel = UIAlertAction(title: "????????????", style: .cancel)
            alertController.addAction(actionTask)
            alertController.addAction(actionDirection)
            alertController.addAction(actionCancel)
            self.present(alertController, animated: true)
            
        } else {
            let userTask = view.annotation as? ModelGroupTasksMap
            uniqueKey = userTask!.id
            let alertController = UIAlertController(title: "??????????????", message: "", preferredStyle: .alert)
            let actionTask = UIAlertAction(title: "?????????????? ?? ?????????????? ???????????????", style: .default)
            { [unowned self] _ in
                performSegue(withIdentifier: References.fromMapActiveTaskToDeclarationTaskScreen, sender: self)
                if let controller = navigationController?.topViewController as? DeclarationOfTasksViewController {
                    controller.uniqueKeyFromMap = uniqueKey
                }
            }
            
            let actionDirection = UIAlertAction(title: "?????????????????? ???????????????", style: .default) { _ in
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
            
            let actionCancel = UIAlertAction(title: "????????????", style: .cancel)
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
