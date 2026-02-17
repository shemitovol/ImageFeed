import UIKit

final class ProfileViewController: UIViewController {
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginLabel = UILabel()
    private var statusLabel = UILabel()
    private var exitButton = UIButton()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YPBlack")
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        let profileImage = UIImage(named: "Photo")
        let imageView = UIImageView(image: profileImage)
        addSubview(imageView)
        self.imageView = imageView

        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YPWhite")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        addSubview(nameLabel)
        self.nameLabel = nameLabel

        let loginLabel = UILabel()
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = UIColor(named: "YPGray")
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(loginLabel)
        self.loginLabel = loginLabel

        let statusLabel = UILabel()
        statusLabel.text = "Hello, world!"
        statusLabel.textColor = UIColor(named: "YPWhite")
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(statusLabel)
        self.statusLabel = statusLabel
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(self.didTapButton)
        )
        exitButton.tintColor = UIColor(named: "YPRed")
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

