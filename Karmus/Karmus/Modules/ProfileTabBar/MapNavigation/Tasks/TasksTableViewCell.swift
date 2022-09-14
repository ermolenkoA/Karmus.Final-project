//
//  TasksTableViewCell.swift
//  Karmus
//
//  Created by VironIT on 24.08.22.
//
import Kingfisher
import UIKit

class TasksTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var declarationLabel: UILabel!
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var taskImageView: UIImageView!
    
    // MARK: - Model
    
    var activeModelTask: ModelActiveTasks? {
        didSet{
            declarationLabel.text = activeModelTask?.type
            dataLabel.text = activeModelTask?.date
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
