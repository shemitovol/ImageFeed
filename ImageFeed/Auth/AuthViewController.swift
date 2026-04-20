import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    let identifierShowWebView = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad () {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard segue.identifier == identifierShowWebView else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let webViewViewController = segue.destination as? WebViewViewController else {
            assertionFailure("Fail to prepare for \(identifierShowWebView)")
            return
        }
        
        webViewViewController.delegate = self
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    private var oAuthService: OAuth2Service {
        OAuth2Service.shared
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String){
        
        UIBlockingProgressHUD.show()
        
        oAuthService.fetchOAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                vc.dismiss(animated: true)
                self.delegate?.didAuthenticate(self)
                print("Token received: \(token)")
            case .failure(let error):
                print("[AuthViewController]: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController){
        vc.dismiss(animated: true)
    }
}
