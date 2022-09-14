//
//  ViewController.swift
//  Karmus
//
//  Created by VironIT on 16.08.22.
//

import UIKit
import FirebaseDatabase

final class ViewController: UIViewController {

    @IBOutlet private weak var mainActivityIndicatorView: UIActivityIndicatorView!
    
    private var isAnimationEnabled = false
    var accountWasBlocked = false
    var wasForceExit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainActivityIndicatorView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        isAnimationEnabled
            ? mainActivityIndicatorView.startAnimating()
            : mainActivityIndicatorView.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if wasForceExit {
            showAlert("В акаунте произошли серьезные изменения", "Вы были усиленно выгнаны", where: self)
            wasForceExit = false
        } else if accountWasBlocked {
            showAlert("Ваш аккаунт был заблокирован", "Свяжитесь с администрацией", where: self)
            accountWasBlocked = false
        }
    }

    @IBAction private func didTapToIdentification(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardNames.identificationScreen, bundle: nil)
        guard let identificationVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
            return
        }
        
        self.navigationController?.pushViewController(identificationVC, animated: true)
    }
    
    @IBAction private func didTapSingUpButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardNames.registrationScreen, bundle: nil)
        guard let registrationVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
            return
        }
        
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
}

extension ViewController: ChangeActivityIndicatorStatusProtocol {
    
    func startActivityIndicator() {
        isAnimationEnabled = true
        mainActivityIndicatorView?.startAnimating()
    }
    
    func stopActivityIndicator() {
        isAnimationEnabled = false
        mainActivityIndicatorView?.stopAnimating()
    }
    
}
