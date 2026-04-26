import Foundation
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: Properties
    
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutService
    var onLogout: (() -> Void)?
    
    // MARK: Init
    init(
        profileService: ProfileServiceProtocol,
        imageService: ProfileImageServiceProtocol,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.profileService = profileService
        self.imageService = imageService
        self.logoutService = logoutService
    }
    
    // MARK: Private Methods
    
    private func loadAvatar(username: String) {
        imageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString) else {
                    self.view?.displayAvatar(url: nil)
                    return
                }
                
                self.view?.displayAvatar(url: url)
            case .failure:
                self.view?.displayAvatar(url: nil)
            }
        }
    }
    
    // MARK: Lifecycle
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        let viewModel = ProfileViewModel(
            name: profile.name.isEmpty ? "Имя не указано" : profile.name,
            login: profile.loginName.isEmpty ? "@неизвестный пользователь" : profile.loginName,
            bio: profile.bio?.isEmpty ?? true ? "Профиль не заполнен" : profile.bio ?? "Профиль не заполнен"
        )
        
        view?.displayProfile(viewModel)
        loadAvatar(username: profile.username)
    }
    
    // MARK: Public Methods
    
    func didTapLogout() {
        logoutService.logout()
        onLogout?()
    }
}
