import UIKit

final class ProfileViewController: UIViewController {
    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginLabel = UILabel()
    private lazy var statusLabel = UILabel()
    private lazy var exitButton = UIButton()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupViews()
        setupConstraints()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails (with: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
    
    private func updateProfileDetails (with profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        loginLabel.text = profile.loginName.isEmpty
            ? "@неизвестный пользователь"
            : profile.loginName
        statusLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }
    
    private func setupViews() {
        let profileImage = UIImage(resource: .photo)
        let imageView = UIImageView(image: profileImage)
        addSubview(imageView)
        self.imageView = imageView

        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        addSubview(nameLabel)
        self.nameLabel = nameLabel

        let loginLabel = UILabel()
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = UIColor(resource: .ypGray)
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(loginLabel)
        self.loginLabel = loginLabel

        let statusLabel = UILabel()
        statusLabel.text = "Hello, world!"
        statusLabel.textColor = UIColor(resource: .ypWhite)
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(statusLabel)
        self.statusLabel = statusLabel
        
        let exitButton = UIButton.systemButton(
            with: UIImage(resource: .exit),
            target: self,
            action: #selector(self.didTapButton)
        )
        exitButton.tintColor = UIColor(resource: .ypRed)
        addSubview(exitButton)
        self.exitButton = exitButton
    }
    
    private func addSubview(_ subView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    @objc
    private func didTapButton() {
        
    }
}

