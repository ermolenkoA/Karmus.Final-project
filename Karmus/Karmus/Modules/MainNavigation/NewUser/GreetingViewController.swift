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
    
    private var tapCounter = 7
    private var login: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let fillInfoVC = segue.destination as? FillMainProfileInfoVC else{
            return
        }
        guard let login = login else {
            return
        }
        (fillInfoVC as SetLoginProtocol).setLogin(login: login)
        (fillInfoVC as NewUserProtocol).calledByNewUser()
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
        textLabel.text = "При выполнении заданий, которые предоставляются предоставляются партнёрами ты получаешь внутреннюю валюту - Карму. Она нужна для того, чтобы участвовать в розыгрышах, но также ты  можешь обменять её на купоны у партнёров.  В Karmus это является главным видом мотивации, однако существуют так же респекты и награды."
        UIView.animate(withDuration: 2) { [weak self] in
            self?.mainView.alpha = 1
        } completion: { [weak self] _ in
            self?.nextButton.alpha = 1
            self?.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func showFourthSlide() {
        titleLabel.text = "Респекты и награды"
        photoImageView.image = UIImage(named: "pngSlide4")
        textLabel.text = "После того, как ты выполнил задание, его создатели могут добавить тебе респект на аккаунт. Респекты повышают доверие к профилю, благодаря ним тебя будут чаще приглашать на задания и различные мероприятия. Награды присуждаются по мере ведения профиля, они будут показываться в  профиле и рассказывают о достижениях в нашем приложении."
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
        textLabel.text = "Создатели заданий так же могут ставить дизреспекты, если либо ты не отметился на задании, либо произвел негативное впечатление. Поэтому никогда не пропускай задания и выполняй их добросовестно!"
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
        textLabel.text = "В нашем приложение существуют 4 главные странницы: \"аккаунт\",  \"карта и задания\", \"чат\",  \"бонусы&ивенты\". Разберём их подробнее."
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
            performSegue(withIdentifier: References.fromNewUserScreentoFillMainInfo, sender: self)
        }
    }
    
}

// MARK: - SetLoginProtocol

extension GreetingViewController: SetLoginProtocol {
    func setLogin(login: String) {
        self.login = login
    }
}


