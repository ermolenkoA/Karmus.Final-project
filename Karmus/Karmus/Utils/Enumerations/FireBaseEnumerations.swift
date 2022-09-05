//
//  FireBaseManagerEnum.swift
//  Karmus
//
//  Created by User on 8/26/22.
//

import Foundation
import FirebaseDatabase

enum FireBaseRequestResult {
    case found
    case notFound
    case error
}

enum FireBaseOpenProfileResult {
    case success
    case failure
    case error
}

enum FireBaseRequestMode {
    case findLogin
    case findPhone
}
