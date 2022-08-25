//
//  TasksTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
