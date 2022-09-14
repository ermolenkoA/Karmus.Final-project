//
//  ActiveTasksViewCell.swift
//  Karmus
//
//  Created by VironIT on 25.08.22.
//
import KeychainSwift
import Kingfisher
import UIKit

class ActiveTasksViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var taskImageView: UIImageView!
    @IBOutlet private weak var declarationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Model
    
    var activeModelTask: ModelActiveTasks? {
        didSet{
            declarationLabel.text = activeModelTask?.type
            dateLabel.text = activeModelTask!.date
            let url = URL(string: activeModelTask!.photo)
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
