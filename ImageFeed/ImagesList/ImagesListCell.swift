import UIKit

class ImagesListCell: UITableViewCell{
    @IBOutlet var CellImage: UIImageView!
    @IBOutlet var DateLabel: UILabel!
    @IBOutlet var LikeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
}
