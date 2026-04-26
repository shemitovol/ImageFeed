import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func updateTableView(oldCount: Int, newCount: Int)
    func updateCell(at indexPath: IndexPath)
    func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func willDisplayCell(at index: Int)
    func didTapLike(at index: Int)
}
