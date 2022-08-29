//
//  ActiveTasksViewCell.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//

import UIKit

class ActiveTasksViewCell: UITableViewCell {

    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
