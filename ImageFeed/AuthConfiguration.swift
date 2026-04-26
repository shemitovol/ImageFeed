import Foundation

enum Constants {
    static let accessKey = "pRoY3OOyazPpsF_VcAA7fdeGMG1A5j9SgtrDsnpTHGY"
    static let secretKey = "ibUtvV17vB8NtovoLEcZWv9I9ObZ1DzH6yL7dk7GTyI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    init (accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURLString: String, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration{
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURLString: Constants.defaultBaseURLString,
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
}
