import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let presenter
            else { return }
            viewController.imageURL = presenter.photo(at: indexPath.row).largeImageURL
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            ) as? ImagesListCell,
            let presenter
        else {
            return UITableViewCell()
        }
        
        let photo = presenter.photo(at: indexPath.row)
        let placeholder = UIImage(resource: .placeholder)
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder)
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
        
        guard let presenter else { return 0 }
        let photo = presenter.photo(at: indexPath.row)
        
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
        presenter?.willDisplayCell(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard
            let indexPath = tableView.indexPath(for: cell)
        else { return }

        UIBlockingProgressHUD.show()
        presenter?.didTapLike(at: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableView(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
        UIBlockingProgressHUD.dismiss()
    }
    
    func updateCell(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
              let presenter
        else { return }
        
        let photo = presenter.photo(at: indexPath.row)
        cell.setIsLiked(photo.isLiked)
        UIBlockingProgressHUD.dismiss()
    }
    
    func showLikeError() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось поставить/снять лайк",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
