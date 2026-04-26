import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    var didChangeNotification: Notification.Name { get }

    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

