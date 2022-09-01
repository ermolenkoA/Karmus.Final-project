//
//  FillProfileInfoProtocols.swift
//  Karmus
//
//  Created by VironIT on 9/1/22.
//

import UIKit

protocol NewUserProtocol {
    func calledByNewUser()
}

protocol UpdateTableViewTitleProtocol {
    func update(with data: [String])
}

protocol SetSenderProtocol {
    func setSender(_ sender: UIViewController)
}

protocol SetCityProtocol {
    func setCity(_ city: String)
}
