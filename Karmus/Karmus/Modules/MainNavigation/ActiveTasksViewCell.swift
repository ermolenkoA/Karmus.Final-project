//
//  ActiveTasksViewCell.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//
import Kingfisher
import UIKit

class ActiveTasksViewCell: UITableViewCell {

    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var activeModelTask: ModelTasks? {
        didSet{
            declarationLabel.text = activeModelTask?.declaration
            dateLabel.text = activeModelTask?.date
            let url = URL(string: activeModelTask!.imageURL)
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
