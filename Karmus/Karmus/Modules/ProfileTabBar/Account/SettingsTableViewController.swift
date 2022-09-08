//
//  SettingsTableViewController.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit

final class SettingsTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var conclusion: ((String) -> ())?
    private var profileType = ""
    private var settings = [String] ( arrayLiteral:
        "Изменить имя и фамилию",
        "Изменить логин",
        "Изменить пароль"
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.isScrollEnabled = false
        tableView.delegate = self
        
        switch profileType {
        
        case FBProfileTypes.admin:
            settings.append("@ Удалить аккаунт")
            settings.append("@ Блокировка аккаунта")
            settings.append("@ Изменить тип аккаунта")
        case FBProfileTypes.user:
            break
        case FBProfileTypes.sponsor:
            settings.removeFirst()
            settings.insert("Изменить имя спонсора", at: 0)
            
        default:
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        preferredContentSize.height = tableView.contentSize.height
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        let setting = settings[indexPath.row]
        cell.textLabel?.text = setting

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: false, completion: nil)
        conclusion?(settings[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - GetProfileTypeProtocol

extension SettingsTableViewController: GetProfileTypeProtocol {
    func getProfileType(_ profileType: String){
        self.profileType = profileType
    }
}

// MARK: - GetClosureProtocol

extension SettingsTableViewController: GetClosureProtocol {
    func getClosure(_ closure: @escaping (String) -> ()) {
        conclusion = closure
    }
    
}

