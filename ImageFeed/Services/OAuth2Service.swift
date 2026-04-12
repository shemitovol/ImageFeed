import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken (
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest)) 
                return
            }
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let newTask = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                self.task = nil
                self.lastCode = nil
                
                switch result {
                case .success(let data):
                    do {
                        let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        let token = tokenResponse.access_token
                        self.tokenStorage.token = token
                        completion(.success(token))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Network or HTTP error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        newTask.resume()
    }
}

