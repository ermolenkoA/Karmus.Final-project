//
//  ComplitedTasksTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 4.09.22.
//

import Kingfisher
import UIKit

class ComplitedTasksTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var declarationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var taskImageView: UIImageView!
    
    // MARK: - Model
    
    var compliteModelTasks: ModelActiveTasks? {
        didSet {
            declarationLabel.text = compliteModelTasks?.type
            dateLabel.text = compliteModelTasks!.date
            let url = URL(string: compliteModelTasks!.photo)
                if let url = url {
                KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    self.taskImageView.image = image
                    self.taskImageView.kf.indicatorType = .activity
                    
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
