//
//  TaskMapViewController.swift
//  Karmus
//
//  Created by VironIT on 31.08.22.
//
import Firebase
import MapKit
import UIKit


class TaskMapViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapContainer: UIView!
    
    var typeFromCreation: String?
    var dateFromCreation: String?
    var declorationFromCreation: String?
    var imageFromCreation = UIImage()
    var imageViewFromCreation = UIImageView()
    var longitudeCoordinate: Double?
    var latitudeCoordinate: Double?
    var resultAddress: String?
    var resultDeleagte: GetAddress?
    var switchFromCreation: Bool?
    
    var refActiveTasks: DatabaseReference!
    var refGroupActiveTasks: DatabaseReference!
    
    var refTasksCoordinates: DatabaseReference!
    var taskCoordinate: CLLocationCoordinate2D!
    var uniqueKey: String?
//    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    var searchController: UISearchController!  = .init(searchResultsController: ResultsMapViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.delegate = self
        refGroupActiveTasks = Database.database().reference().child("GroupTasks")
        refActiveTasks = Database.database().reference().child("ActiveTasks")
  //      refTasksCoordinates = refTasks.child("Coordinates")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView = nil
        searchController = nil
        refActiveTasks = nil
        refGroupActiveTasks = nil
        refTasksCoordinates = nil
        
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        if longitudeCoordinate != nil && latitudeCoordinate != nil{
            if switchFromCreation == true {
                self.saveFIRData(reference: refGroupActiveTasks)
                if let controller = navigationController?.viewControllers.first as? MapViewController {
                navigationController?.popToViewController(controller, animated: true)
                }
            }else {
                self.saveFIRData(reference: refActiveTasks)
                if let controller = navigationController?.viewControllers.first as? MapViewController {
                navigationController?.popToViewController(controller, animated: true)
                }
            }
        }else {
            showAlert()
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Ошибка", message: "Вы не указали адрес", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func searchWithAddress(_ sender: Any) {
        
        searchController.searchBar.backgroundColor = .secondarySystemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        (searchController.searchResultsController as? SetDelegate)?.setDelegate(sender: self)
        self.present(searchController, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultsMapViewController else  {
            return
        }
        
        resultVC.delegate = self
        resultVC.addressDelegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func uploadPhoto(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
   //     let key = refTasks.childByAutoId().key
        let storageRef = Storage.storage().reference().child("imageTasks").child("my photo")
        let imageData = imageViewFromCreation.image?.jpegData(compressionQuality: 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) {(metaData, error) in
            guard metaData != nil else { print("error in save image")
                completion(nil)
                return
            }
                print("success")
                storageRef.downloadURL(completion: {(url, error) in
                    completion(url)
                })
            }
    }
   

    func saveTask(imageURL: URL, referenceTask: DatabaseReference, completion: @escaping ((_ url: URL?) -> ())) {
            let key = referenceTask.childByAutoId().key
        uniqueKey = key
        let task = ["address": resultAddress!,
                    "longitudeCoordinate": longitudeCoordinate!,
                    "latitudeCoordinate": latitudeCoordinate!,
                    "taskName": declorationFromCreation!,
                    "taskDate": dateFromCreation!,
                    "imageURL": imageURL.absoluteString,
                    "taskType": typeFromCreation!
                    
            ] as! [String: AnyObject]
        referenceTask.child(key!).setValue(task)
        
        }
        
    func saveFIRData(reference: DatabaseReference){
        self.uploadPhoto(imageFromCreation){ url in
            if url == nil {
                print("error1")
                return
            }else{
            
                self.saveTask(imageURL: url!, referenceTask: reference){ success in
                if success != nil {
                    print("Eeee")
                }else {
                    print("error")
                    }
                }
            }
        }
    }
//    func passData(){
//        let storyboard = UIStoryboard(name: "DeclataionOfTasksScreen", bundle: nil)
//        if let declarationTasksVC = storyboard.instantiateViewController(identifier: "DeclarationOfTasksViewController") as? DeclarationOfTasksViewController {
//            declarationTasksVC.uniqueKeyFromActiveTasks = uniqueKey
//
//            print(declarationTasksVC.uniqueKeyFromActiveTasks!)
//        }
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//                let controller = segue.destination as! DeclarationOfTasksViewController
//        controller.uniqueKeyFromActiveTasks = uniqueKey
//        print(uniqueKey)
//            }

}

extension TaskMapViewController: ResultsMapViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchController.dismiss(animated: true)
        searchController.searchBar.resignFirstResponder()

        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)

        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        taskCoordinate = coordinates
        longitudeCoordinate = coordinates.longitude
        latitudeCoordinate = coordinates.latitude
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: 600,
            longitudinalMeters: 600
        ),
                          animated: true)
    }
}


extension TaskMapViewController: GetAddress {
    func resultAddress(address: String) {
        self.resultAddress = address
    }
}

    
