//
//  PopTypeOfTaskTableViewController.swift
//  Karmus
//
//  Created by VironIT on 11.09.22.
//

import UIKit

class PopTypeOfTaskTableViewController: UITableViewController {
    
    private var handler: ((String) -> ())?
    
    var typeArray = ["Общее",
                     "Экологическое",
                     "Культурное",
                     "Спортивное",
                     "Медицинское"
                     ]
   
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 160, height: tableView.contentSize.height)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let textData = typeArray[indexPath.row]
        cell.textLabel?.text = textData
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let topic = typeArray[indexPath.row]
        handler?(topic)
    }

}

    // MARK: - GetHandlerProtocol

extension PopTypeOfTaskTableViewController: GetHandlerProtocol {
    func getHandler(_ handler: @escaping (String) -> ()) {
        self.handler = handler
    }
}

