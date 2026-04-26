import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfile(_ viewModel: ProfileViewModel)
    func displayAvatar(url: URL?)
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var onLogout: (() -> Void)? { get set }
    
    func viewDidLoad()
    func didTapLogout()
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func reset()
}
