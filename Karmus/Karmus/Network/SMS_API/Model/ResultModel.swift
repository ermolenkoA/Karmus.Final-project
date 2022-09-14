//
//  ResultModel.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

class ResultModel: Codable {
    let balance: String
    
    init(balance: String, viber_balance: String) {
        self.balance = balance
    }
    
    var about: String {
        "\(self.balance)"
    }
}
