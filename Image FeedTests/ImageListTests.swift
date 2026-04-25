@testable import ImageFeed
import XCTest
import Foundation

final class ImagesListPresenterTests: XCTestCase {
    func testViewDidLoadCallsFetchPhotos() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(service: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        presenter.viewDidLoad()

        XCTAssertTrue(service.fetchNextPageCalled)
    }

    func testPhotosCountReturnsCorrectValue() {
        let service = ImagesListServiceSpy()
        service.photos = [Photo.mock(), Photo.mock()]
        let presenter = ImagesListPresenter(service: service)
        presenter.viewDidLoad()

        XCTAssertEqual(presenter.photosCount, 2)
    }

    func testPhotoAtIndexReturnsCorrectPhoto() {
        let service = ImagesListServiceSpy()
        let photo = Photo.mock()
        service.photos = [photo]
        let presenter = ImagesListPresenter(service: service)
        presenter.viewDidLoad()
        let result = presenter.photo(at: 0)

        XCTAssertEqual(result.id, photo.id)
    }

    func testDidTapLikeCallsService() {
        let service = ImagesListServiceSpy()
        service.photos = [Photo.mock()]
        let presenter = ImagesListPresenter(service: service)
        presenter.viewDidLoad()
        presenter.didTapLike(at: 0)

        XCTAssertTrue(service.changeLikeCalled)
    }

    func testWillDisplayLastCellLoadsNextPage() {
        let service = ImagesListServiceSpy()
        service.photos = [Photo.mock()]
        let presenter = ImagesListPresenter(service: service)
        presenter.viewDidLoad()
        presenter.willDisplayCell(at: 0)

        XCTAssertTrue(service.fetchNextPageCalled)
    }
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var didChangeNotification: Notification.Name = Notification.Name("test")
    var fetchNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage() {
        fetchNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    
    var updateTableViewCalled = false
    var updateCellCalled = false
    var showLikeErrorCalled = false
    var lastOldCount: Int?
    var lastNewCount: Int?
    
    func updateTableView(oldCount: Int, newCount: Int) {
        updateTableViewCalled = true
        lastOldCount = oldCount
        lastNewCount = newCount
    }
    
    func updateCell(at indexPath: IndexPath) {
        updateCellCalled = true
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
}

extension Photo {
    static func mock() -> Photo {
        Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }
}
