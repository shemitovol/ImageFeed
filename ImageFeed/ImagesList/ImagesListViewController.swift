import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageIdentifier = "ShowSingleImage"
    private let today = Date()
    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @objc
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = ImagesListService.shared.photos
        
        guard newPhotos.count > oldCount else { return }
        
        photos = newPhotos
        
        let indexPaths = (oldCount..<newPhotos.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        let placeholder = UIImage(resource: .placeholder)
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholder
            )
        }
        
        cell.dateLabel.text = DateFormatter.localizedString(
            from: photo.createdAt ?? Date(),
            dateStyle: .long,
            timeStyle: .none
        )
        
        cell.setIsLiked(photo.isLiked)
        
        cell.delegate = self
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let photo = photos[indexPath.row]
        
        let insets = UIEdgeInsets(top: 16, left: 4, bottom: 16, right: 4)
        let width = tableView.bounds.width - insets.left - insets.right
        
        let scale = width / photo.size.width
        let height = photo.size.height * scale
        
        return height + insets.top + insets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) {result in
            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showLikeErrorAlert()
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось поставить/снять лайк",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
