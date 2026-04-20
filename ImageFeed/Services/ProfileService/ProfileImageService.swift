import UIKit

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private init () {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "ProfileImageService)", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<UserResult, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                
                let url = userResult.profileImage.small
                self.avatarURL = url
                completion(.success(url))
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage.small])

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    func reset() {
        avatarURL = nil
        task?.cancel()
        task = nil
    }
}
