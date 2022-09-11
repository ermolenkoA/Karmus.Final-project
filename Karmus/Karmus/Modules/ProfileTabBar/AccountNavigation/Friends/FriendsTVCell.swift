//
//  FriendsTVCell.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit

final class FriendsTVCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var friendView: UIView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cityAndAgeLabel: UILabel!
    @IBOutlet private weak var onlineStatusLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!

    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

// MARK: - SetFriendsCellInfoProtocol

extension FriendsTVCell: SetFriendsCellInfoProtocol {
    
    func setFriendsInfo(photo: UIImage, name: String,
                        city: String, onlineStatus:String,
                        login: String, dateOfBirth: Date? = nil) {
        
        photoImageView.image = photo
        photoImageView.kf.indicatorType = .activity
        nameLabel.text = name
        loginLabel.text = "@" + login
        if let date = dateOfBirth {
            cityAndAgeLabel.text = city + ", " + String(date.age())
        } else {
            cityAndAgeLabel.text = city
        }
        
        onlineStatusLabel.text = onlineStatus
        
        switch onlineStatus {
        
        case FBOnlineStatuses.offline:
            onlineStatusLabel.textColor = .lightGray
        case FBOnlineStatuses.online:
            onlineStatusLabel.textColor = .green
        case FBOnlineStatuses.blocked:
            onlineStatusLabel.textColor = .red
        default:
            onlineStatusLabel.textColor = .clear
            
        }
        
    }
}
