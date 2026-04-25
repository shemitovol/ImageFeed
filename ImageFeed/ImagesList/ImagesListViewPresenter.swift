import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewProtocol?
    private let service: ImagesListServiceProtocol
    private var photos: [Photo] = []
    
    init(service: ImagesListServiceProtocol) {
        self.service = service
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func viewDidLoad() {
        photos = service.photos
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangePhotos),
            name: service.didChangeNotification,
            object: nil
        )
        
        service.fetchPhotosNextPage()
    }
    
    @objc
    private func didChangePhotos() {
        let oldCount = photos.count
        let newPhotos = service.photos
        guard newPhotos.count > oldCount else { return }
        photos = newPhotos
        view?.updateTableView(oldCount: oldCount, newCount: newPhotos.count)
    }
    
    func photo(at index: Int) -> Photo {
        guard index < photos.count else { fatalError("Index out of range") }
        return photos[index]
    }
    
    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            service.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at index: Int) {
        guard index < photos.count else { return }
        let photo = photos[index]
        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.service.photos
                self.view?.updateCell(at: IndexPath(row: index, section: 0))
            case .failure:
                self.view?.showLikeError()
            }
        }
    }
}
