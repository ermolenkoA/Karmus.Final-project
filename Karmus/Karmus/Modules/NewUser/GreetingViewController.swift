//
//  GreetingViewController.swift
//  Karmus
//
//  Created by VironIT on 8/30/22.
//

import UIKit
import KeychainSwift

final class GreetingViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var nextButton: UIButton!
    
    // MARK: - Private Properties
    
    private var tapCounter = 1
    private var login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Вернуться"
        navigationItem.backBarButtonItem = backItem

        showFirstSlide()
    }
    
    private func showFirstSlide() {
        titleLabel.text = "Добро пожаловать в Karmus!"
        photoImageView.image = UIImage(named: "iconKarmusLogo")
        textLabel.text = "Сейчас мы поближе познакомим тебя этим приложением: расскажем о наших целях, какую мотивацию мы предлагаем, как работать с приложением и поможем тебе стать частью нашей команды. Так что не отвлекайся"
    }
    
    private func showSecondSlide() {
        titleLabel.text = "Кратко о целях Karmus"
        photoImageView.image = UIImage(named: "pngSlide2")
        textLabel.text = "Наша команда разработала это приложение, для объединения людей, стремящихся помочь окружающему миру. Оно значительно упрощает коммуникацию между волонтёрами, помогает найти подходящее задание, а так же создать задание для других волонтёров. Мы хотим, чтобы волонтёрство распространялось среди людей и даём возможность повысить свою карму."
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showThirdSlide() {
        titleLabel.text = "Кстати о карме"
        photoImageView.image = UIImage(named: "pngSlide3")
        textLabel.text = "При выполнении заданий, которые предоставляются предоставляются партнёрами ты получаешь внутреннюю валюту - Карму. Она нужна для того, чтобы участвовать в розыгрышах, но также ты  можешь обменять её на купоны у партнёров.  В Karmus это является главным видом мотивации, однако существуют так же респекты."
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showFourthSlide() {
        titleLabel.text = "Респекты"
        photoImageView.image = UIImage(named: "pngSlide4")
        textLabel.text = "После того, как ты выполнил задание, cоздатель его проверяет и отмечает, выполнил ты его или нет. Респекты повышают доверие к профилю, благодаря ним тебя будут чаще приглашать на задания и различные мероприятия."
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showFifthSlide() {
        titleLabel.text = "Подводные камни"
        photoImageView.image = UIImage(named: "pngSlide5")
        textLabel.text = "Если ты произвел на задании негативное впечатление или не выполнил задания - у тебя отнимется респект и не начислится карма. Поэтому никогда не пропускай задания и выполняй их добросовестно!"
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showSixthSlide() {
        titleLabel.text = "Работа с приложением"
        photoImageView.image = UIImage(named: "pngSlide6")
        textLabel.text = "В нашем приложение существуют 4 главные странницы: \"Аккаунт\",  \"Карта с заданиями\", \"Чат\",  \"Купоны\". На странице аккаунта ты можешь узнать подробную информацию о своем профиле, изменять её и добавлять друзей. На странице с картой находится основная часть приложения -  задания. Задания может создавать и выбирать любой пользователь, за выполнения которых присуждаются награды. На странице купонов ты можешь обменять свою карму на купоны от партнеров. На странице чата ты можешь писать любому пользователю и уточнять детали купонов, заданий, а так же обратиться к администрации"
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showSeventhSlide() {
        titleLabel.text = "Заполнение профиля"
        photoImageView.image = UIImage(named: "pngSlide7")
        textLabel.text = "Ну вот и все, краткий гайд по приложению завершён. Надеемся, что все было понятно и у тебя не возникнет трудностей при использовании. Остался последний рывок - заполнение профиля"
        nextButton.setTitle("Начать", for: .normal)
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - IBAction

    @IBAction func didTapNextButton(_ sender: UIButton) {
        tapCounter += 1
        
        if tapCounter < 8 {
            
            sender.alpha = 0.5
            sender.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 2) { [weak self] in
                self?.mainView.alpha = 0
            } completion: { [weak self] _ in
                switch self?.tapCounter {
                case 2:
                    self?.showSecondSlide()
                case 3:
                    self?.showThirdSlide()
                case 4:
                    self?.showFourthSlide()
                case 5:
                    self?.showFifthSlide()
                case 6:
                    self?.showSixthSlide()
                case 7:
                    self?.showSeventhSlide()
                default:
                    break
                }
            }
            
        } else {
            let storyboard = UIStoryboard(name: StoryboardNames.fillMainProfileInfo, bundle: nil)
            guard let fillInfoVC = storyboard.instantiateInitialViewController() else {
                showAlert("Невозможно перейти", "Повторите попытку позже", where: self)
                return
            }
            (fillInfoVC as? NewUserProtocol)?.calledByNewUser()
            navigationController?.pushViewController(fillInfoVC, animated: true)
        }
    }
    
}

