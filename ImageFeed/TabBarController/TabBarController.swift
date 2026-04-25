import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            return
        }
        
        let imagesPresenter = ImagesListPresenter(service: ImagesListService.shared)
        imagesListViewController.configure(imagesPresenter)
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        
        let profilePresenter = ProfilePresenter(
            profileService: ProfileService.shared,
            imageService: ProfileImageService.shared,
            logoutService: ProfileLogoutService.shared
        )
        profileViewController.configure(profilePresenter)
        
        profilePresenter.onLogout = { [weak self] in
            guard let self else { return }
            let splash = SplashViewController()
            self.view.window?.rootViewController = splash
        }
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
