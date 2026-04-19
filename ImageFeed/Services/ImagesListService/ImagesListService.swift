import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
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
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                print("Error:", error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                print("HTTP Error")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let results = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = results.map {Photo(from: $0)}
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.currentPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Ошибка декодинга:", error)
            }
        }
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        guard var components = URLComponents(string: "https://api.unsplash.com/photos") else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components.url else { return nil }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Нет токена")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
