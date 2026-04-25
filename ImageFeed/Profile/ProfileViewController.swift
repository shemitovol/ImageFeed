import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginLabel = UILabel()
    private lazy var statusLabel = UILabel()
    private lazy var exitButton = UIButton()
    private var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupViews()
        setupConstraints()
        presenter?.viewDidLoad()
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
            self.presenter = presenter
            presenter.view = self
        }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        addSubview(imageView)


        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        addSubview(nameLabel)
        loginLabel.textColor = UIColor(resource: .ypGray)
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(loginLabel)
        statusLabel.textColor = UIColor(resource: .ypWhite)
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(statusLabel)
        
        let exitButton = UIButton.systemButton(
            with: UIImage(resource: .exit),
            target: self,
            action: #selector(showLogoutAlert)
        )
        
        exitButton.tintColor = UIColor(resource: .ypRed)
        exitButton.accessibilityIdentifier = "profileExitButton"
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
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default
        ) {[weak self] _ in
            self?.presenter?.didTapLogout()
        })
        
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .default
        ))
        
        present(alert, animated: true)
    }
}

extension ProfileViewController: ProfileViewControllerProtocol {
    func displayProfile(_ viewModel: ProfileViewModel) {
        nameLabel.text = viewModel.name
        loginLabel.text = viewModel.login
        statusLabel.text = viewModel.bio
    }
    
    func displayAvatar(url: URL?) {
        let placeholder = UIImage(systemName: "person.crop.circle.fill")
        
        if let url {
            imageView.kf.setImage(with: url, placeholder: placeholder)
        } else {
            imageView.image = placeholder
        }
    }
}
