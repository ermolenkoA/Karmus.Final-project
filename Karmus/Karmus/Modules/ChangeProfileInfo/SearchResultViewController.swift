//
//  SearchResultViewController.swift
//  Karmus
//
//  Created by VironIT on 9/1/22.
//

import UIKit

final class SearchResultVC: UIViewController {
    
    // MARK: - Private Properties
    
    private var cities = [String]()
    private var myTableView: UITableView!
    private var sender: UIViewController?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        myTableView.isHidden = true
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
}

// MARK: - UITableViewDelegate

extension SearchResultVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        if let sender = sender {
            (sender as? SetCityProtocol)?.setCity(cities[indexPath.row])
        }
        
    }
}

// MARK: - UITableViewDataSource

extension SearchResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        
        cell.textLabel?.text = "\(cities[indexPath.row])"
        
        return cell
    }
    
}

// MARK: - UpdateTableViewTitleProtocol

extension SearchResultVC: UpdateTableViewTitleProtocol {
    func update(with data: [String]) {
        self.cities = data
        myTableView.reloadData()
        myTableView.isHidden = false
    }
}

// MARK: - SetSenderProtocol

extension SearchResultVC: SetSenderProtocol {
    func setSender(_ sender: UIViewController) {
        self.sender = sender
    }
}
