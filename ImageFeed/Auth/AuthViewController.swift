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

}

extension AuthViewController: WebViewViewControllerDelegate {
    private var oAuthService: OAuth2Service {
        OAuth2Service.shared
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String){
        
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        
        oAuthService.fetchOAuthToken(code: code) { result in
            
            UIBlockingProgressHUD.dismiss()
            
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
