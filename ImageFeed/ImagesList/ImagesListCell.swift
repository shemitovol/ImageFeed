import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell{
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.isAccessibilityElement = true
        likeButton.accessibilityIdentifier = "likeButton"
    }
    
    func setIsLiked (_ isLiked: Bool) {
        let image = UIImage(resource: isLiked ? .active : .noActive)
        likeButton.setImage(image, for: .normal)
    }
}
