import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotificationName = Notification.Name("ImagesListServiceDidChange")

    var didChangeNotification: Notification.Name {
        Self.didChangeNotificationName
    }
    
    private(set) var photos: [Photo] = []
    
    private var currentPage = 0
    private var isLoading = false
    private let session = URLSession.shared
    
    private init() {}
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        let nextPage = currentPage + 1
        
        guard let request = makeRequest(page: nextPage) else {
            isLoading = false
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            switch result {
            case .success(let result):
                let newPhotos = result.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    self.photos.append(contentsOf: newPhotos)
                    self.currentPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: Self.didChangeNotificationName,
                        object: self
                    )
                }
            case .failure(let error):
                if error is DecodingError {
                        print("[ImagesListService.fetchPhotosNextPage]: Decoding error - \(error.localizedDescription)")
                    }
                print("[ImagesListService.fetchPhotosNextPage]: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        guard
            var components = URLComponents(string: "https://api.unsplash.com/photos")
        else { return nil }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components.url,
              let token = OAuth2TokenStorage.shared.token
        else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike( photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { [weak self] _, response, error in

            let result: Result<Void, Error>
            if let error = error {
                print("[ImagesListService.changeLike]: \(error.localizedDescription)")
                result = .failure(error)
            } else if
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            {
                guard let self = self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                result = .success(())
            } else {
                result = .failure(NSError(domain: "[ImagesListService.changeLike]: Invalid response", code: 0))
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }
}

extension ImagesListService {
    func reset() {
        photos = []
        currentPage = 0
        isLoading = false
    }
}

extension ImagesListService: ImagesListServiceProtocol {}
