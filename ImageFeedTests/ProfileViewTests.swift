@testable import ImageFeed
import XCTest
import Foundation

@MainActor
final class ProfileViewTests: XCTestCase {
    func testViewDidLoadCallsPresenter() {
        let presenter = ProfilePresenterSpy()
        let vc = ProfileViewController()
        vc.configure(presenter)
        _ = vc.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testDisplayProfileDoesNotCrash() {
        let presenter = ProfilePresenterSpy()
        let vc = ProfileViewController()
        vc.configure(presenter)
        let viewModel = ProfileViewModel(
            name: "Test",
            login: "@test",
            bio: "Bio"
        )
        vc.displayProfile(viewModel)

        XCTAssertTrue(true)
    }
    
    func testDisplayAvatarWithValidURLDoesNotCrash() {
        let presenter = ProfilePresenterSpy()
        let vc = ProfileViewController()
        vc.configure(presenter)
        let url = URL(string: "https://example.com/image.png")
        vc.displayAvatar(url: url)

        XCTAssertTrue(true)
    }
    
    func testDisplayAvatarWithNilDoesNotCrash() {
        let presenter = ProfilePresenterSpy()
        let vc = ProfileViewController()
        vc.configure(presenter)
        vc.displayAvatar(url: nil)

        XCTAssertTrue(true)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var onLogout: (() -> Void)?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
        onLogout?()
    }
}
