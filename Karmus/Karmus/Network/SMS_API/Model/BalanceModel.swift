//
//  BalanceModel.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

struct BalanceModel: Codable {
    let status: String
    let currency: String
    let result: [ResultModel]
    
    private enum CodingKeys: String, CodingKey {
        case status
        case currency
        case result
    }
    
    init(status: String, currency: String, result: [ResultModel]){
        self.status = status
        self.currency = currency
        self.result = result
    }
    
    var about: String { """

MY BALANCE:
    "status" = \(status)
    "currency" = \(currency)
    "balance" = \(result.first?.about ?? "0.0")

""" }
}
