//
//  TaskMapViewController.swift
//  Karmus
//
//  Created by VironIT on 31.08.22.
//
import Firebase
import MapKit
import UIKit

class TaskMapViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapContainer: UIView!
    
    var dateFromCreation: String?
    var declorationFromCreation: String?
    var imageFromCreation = UIImage()
    var imageViewFromCreation = UIImageView()
    var longitudeCoordinate: Double?
    var latitudeCoordinate: Double?
    
    var refTasks: DatabaseReference!
    var refTasksCoordinates: DatabaseReference!
    var taskCoordinate: CLLocationCoordinate2D!
    var uniqueKey: String?
//    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    let searchController = UISearchController(searchResultsController: ResultsMapViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()

      }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.delegate = self
        refTasks = Database.database().reference().child("ActiveTasks")
  //      refTasksCoordinates = refTasks.child("Coordinates")
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        self.saveFIRData()
//        self.saveCoordinate()
    }
    
    @IBAction func searchWithAddress(_ sender: Any) {
        searchController.searchBar.backgroundColor = .secondarySystemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultsMapViewController else  {
            return
        }
        
        resultVC.delegate = self
        
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
   

    func saveTask(imageURL: URL, completion: @escaping ((_ url: URL?) -> ())) {
            let key = refTasks.childByAutoId().key
        uniqueKey = key
        print("creation" + (uniqueKey ?? "nil")!)
//            let date = dateField.text!
//            let decloration = taskDeclorationField.text!
        let task = ["longitudeCoordinate": longitudeCoordinate!,
                    "latitudeCoordinate": latitudeCoordinate!,
                        "taskName": declorationFromCreation!,
                        "taskDate": dateFromCreation!,
                        "imageURL": imageURL.absoluteString
            ] as! [String: AnyObject]
        self.refTasks.child(key!).setValue(task)

        }
    
    func saveCoordinate(){
        let key = refTasksCoordinates.childByAutoId().key
        let taskCoordinate = ["coordinate": taskCoordinate]
        as! [String: Double]
        self.refTasksCoordinates.child(key!).setValue(taskCoordinate)
    }
        
    
        
    func saveFIRData(){
        self.uploadPhoto(imageFromCreation){ url in
            if url == nil {
                print("error1")
                return
            }else{
            
            self.saveTask(imageURL: url!){ success in
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
