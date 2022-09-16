//
//  ResultMapViewController.swift
//  Karmus
//
//  Created by VironIT on 31.08.22.
//
import CoreLocation
import UIKit

final class ResultsMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    var delegate: ResultsMapViewControllerDelegate?
    var addressDelegate: GetAddress?
    
    
    var sender: UIViewController?
    var resultAddress: String?
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    
    // MARK: - Private Functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        let place = places[indexPath.row]
        GooglePlacesManager.shared.resolveLocation(for: place) { [weak self] result in
            
            switch result {
            case .success(let coordinate):
                DispatchQueue.main.async { [self] in
                    self?.delegate?.didTapPlace(with: coordinate)
                    self?.addressDelegate?
                        .resultAddress(address: self!.places[indexPath.row].name)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }

    
    // MARK: - Public Functions

    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
    }
}

    // MARK: - SetDelegate

extension ResultsMapViewController: SetDelegate{
    func setDelegate(sender: UIViewController) {
        self.sender = sender
    }
}

