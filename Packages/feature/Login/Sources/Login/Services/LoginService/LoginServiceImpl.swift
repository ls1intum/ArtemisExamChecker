//
//  File.swift
//  
//
//  Created by Sven Andabaka on 09.01.23.
//

import Foundation
import APIClient
import UserStore
import Common

class LoginServiceImpl: LoginService {
    
    private let client = APIClient()

    struct LoginUser: APIRequest {
        typealias Response = RawResponse
        
        var username: String
        var password: String
        var rememberMe: Bool
        
        var method: HTTPMethod {
            return .post
        }
        
        var resourceName: String {
            return "api/authenticate"
        }
    }
    
    func login(username: String, password: String, rememberMe: Bool) async -> NetworkResponse {
        let result = await client.send(LoginUser(username: username, password: password, rememberMe: rememberMe))
        
        switch result {
        case .success:
            UserSession.shared.setUserLoggedIn(isLoggedIn: true, shouldRemember: rememberMe)
            return .success
        case .failure(let error):
            return NetworkResponse(error: error)
        }
    }
}

public struct EmptyResponse: Decodable {
    
}
