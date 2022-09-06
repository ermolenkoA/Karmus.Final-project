//
//  ComplitedTasksTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 4.09.22.
//
import Kingfisher
import UIKit

class ComplitedTasksTableViewCell: UITableViewCell {

    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var taskImageView: UIImageView!
    
    var compliteModelTasks: ModelTasks? {
        didSet{
            declarationLabel.text = compliteModelTasks?.type
            dataLabel.text = compliteModelTasks?.date
            let url = URL(string: compliteModelTasks!.imageURL)
            if let url = url as? URL {
                KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                self.taskImageView.image = image
                self.taskImageView.kf.indicatorType = .activity
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
