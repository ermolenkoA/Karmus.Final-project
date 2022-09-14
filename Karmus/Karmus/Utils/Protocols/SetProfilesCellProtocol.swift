//
//  SetProfilesCellProtocol.swift
//  Karmus
//
//  Created by VironIT on 9/11/22.
//

import UIKit

protocol SetProfilesCellProtocol {
    func setProfilesCell(photo: UIImage, name: String,
                          city: String, onlineStatus: String,
                          profileType: String, login: String,
                          dateOfBirth: Date?)
}
