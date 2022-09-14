//
//  CouponModel.swift
//  Karmus
//
//  Created by VironIT on 9/12/22.
//

import UIKit

struct CouponModel {
    let name: String
    let description: String
    let codes: [String]
    let sponsorLogin: String
    let price: UInt
}

struct CouponInfoModel {
    let id: String
    let name: String
    let description: String
    let remainingAmount: UInt
    let sponsorLogin: String
    let sponsorPhoto: UIImage
    let sponsorName: String
    let price: UInt
}

struct UserCouponInfoModel {
    let id: String
    let code: String
    let name: String
    let description: String
    let sponsorLogin: String
    let sponsorPhoto: UIImage
    let sponsorName: String
}
