//
//  RegistrationEnumeration.swift
//  Karmus
//
//  Created by User on 8/21/22.
//

import Foundation

enum RegistrationElements: Int{
    case firstName = 1
    case secondName = 2
    case login = 3
    case password = 4
    case repeatPassword = 5
    case phoneNumber = 6
}

enum ShowOrHide{
    case show, hide
}

enum Result{
    case correct, incorrect
}
