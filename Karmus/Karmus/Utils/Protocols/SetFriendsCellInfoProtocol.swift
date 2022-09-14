//
//  SetFriendsCellInfoProtocol.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit

protocol SetFriendsCellInfoProtocol {
    func setFriendsInfo(photo: UIImage, name: String,
                        city: String, onlineStatus: String,
                        login: String, dateOfBirth: Date?)
}
