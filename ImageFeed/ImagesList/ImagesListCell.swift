import UIKit

class ImagesListCell: UITableViewCell{
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
}
