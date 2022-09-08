//
//  ProfileSettingsProtocols.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import Foundation

protocol GetProfileTypeProtocol {
    func getProfileType(_ profileType: String)
}
protocol GetClosureProtocol {
    func getClosure(_ closure: @escaping (String) -> ())
}
