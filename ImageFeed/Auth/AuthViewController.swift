import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

class AuthViewController: UIViewController {
    let identifireShowWebView = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad () {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == identifireShowWebView{
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Fail to prepare for \(identifireShowWebView)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    private var oAuthService: OAuth2Service {
        OAuth2Service.shared
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String){
        oAuthService.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                self.delegate?.didAuthenticate(self)
                print("Token received: \(token)")
            case .failure(let error):
                print("Failed to fetch token: \(error)")
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController){
        vc.dismiss(animated: true)
    }
}

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

final class OAuth2TokenStorage {
    private let key = "BearerToken"
    
    var token: String? {
        get{
            UserDefaults.standard.string(forKey: key)
        }
        set{
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = tokenResponse.access_token
                    self?.tokenStorage.token = token
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
        task.resume()
    }
}
