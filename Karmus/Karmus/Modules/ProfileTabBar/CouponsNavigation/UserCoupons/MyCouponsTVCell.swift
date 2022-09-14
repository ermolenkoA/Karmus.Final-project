//
//  MyCouponsTVCell.swift
//  Karmus
//
//  Created by VironIT on 9/13/22.
//

import UIKit

final class MyCouponsTVCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var couponCodeLabel: UILabel!
    @IBOutlet private weak var sponsorNameLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!

}

// MARK: - FillMyCouponProtocol

extension MyCouponsTVCell: FillMyCouponProtocol {
    func fillCoupon(photo: UIImage, code: String, title: String, sponsorName: String, login: String) {
        photoImageView.image = photo
        titleLabel.text = title
        couponCodeLabel.text = "Номер купона: " + code
        sponsorNameLabel.text = sponsorName
        loginLabel.text = "@" + login
    }
}
