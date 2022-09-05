//
//  ChoosePreferencesViewController.swift
//  Karmus
//
//  Created by VironIT on 9/2/22.
//

import UIKit

final class ChoosePreferencesViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var sender: UIViewController?
    private var activePreferences = [String]()
    private var allPreferences = [String]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach { $0.backgroundColor = .none }
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        getAllpreferences()
    }
    
    // MARK: - Private functions
    
    private func getAllpreferences(){
        
        FireBaseDataBaseManager.getTopics { [weak self] preferences in
            guard let preferences = preferences else {
                self?.errorLabel.isHidden = false
                return
            }
            self?.allPreferences = preferences.sorted()
            self?.setupLabels()
        }
    }
    
    private func setupLabels() {
        var topPosition = CGFloat(10)
        var leftPosition = CGFloat(5)
        
        for preference in allPreferences {
            let button = UIButton()
            button.setTitle(preference, for: .normal)
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            button.tintColor = .white
            button.backgroundColor = activePreferences.contains(preference) ? .green : .red
            button.layer.cornerRadius = 5
            let width = button.intrinsicContentSize.width + 4
            let height = button.intrinsicContentSize.height - 4

            if leftPosition + width + 5 < UIScreen.main.bounds.width - 38{
                button.frame = CGRect(x: leftPosition, y: topPosition, width: width, height: height)
                leftPosition += width + 5
            } else {
                leftPosition = width + 10
                topPosition += height + 5
                button.frame = CGRect(x: 5, y: topPosition, width: width, height: height)
            }
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            mainView.addSubview(button)
            
        }
        
        if let buttonsHeight = mainView.subviews.first?.frame.height {
            mainView.heightAnchor.constraint(equalToConstant: 647).isActive = false
            mainView.heightAnchor.constraint(equalToConstant: topPosition + buttonsHeight + 10).isActive = true
        }
    }
    
    // MARK: - Objc functions
    
    @objc private func didTapButton(sender: UIButton){
        
        if sender.backgroundColor == .green {
            let indexToRemove = activePreferences.firstIndex(where:){
                $0 == sender.titleLabel?.text
            }
            activePreferences.remove(at: indexToRemove!)
            sender.backgroundColor =  .red
        } else {
            activePreferences.append(sender.titleLabel!.text!)
            sender.backgroundColor = .green
        }
        
        (self.sender as? GetPreferencesProtocol)?.getPreferences(activePreferences.sorted())
    }

}

// MARK: - SetSenderProtocol

extension ChoosePreferencesViewController: SetSenderProtocol {
    func setSender(_ sender: UIViewController) {
        self.sender = sender
    }
}

// MARK: - GetPreferencesProtocol

extension ChoosePreferencesViewController: GetPreferencesProtocol {
    func getPreferences(_ preferences: [String]) {
        self.activePreferences = preferences
    }
}
