//
//  AllCouponsTVCell.swift
//  Karmus
//
//  Created by VironIT on 9/13/22.
//

import UIKit

final class AllCouponsTVCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sponsorNameLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!
    
}

// MARK: - FillCouponProtocol

extension AllCouponsTVCell: FillCouponProtocol {
    func fillCoupon(photo: UIImage, title: String, sponsorName: String, login: String) {
        photoImageView.image = photo
        titleLabel.text = title
        sponsorNameLabel.text = sponsorName
        loginLabel.text = "@" + login
    }
}
