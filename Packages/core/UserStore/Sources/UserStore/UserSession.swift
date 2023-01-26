//
//  File.swift
//
//
//  Created by Sven Andabaka on 09.01.23.
//

import Foundation

public class UserSession: ObservableObject {
    
    @Published public private(set) var isLoggedIn: Bool = false
    
    public static let shared = UserSession()
    
    private init() {
        guard let rememberData = KeychainHelper.shared.read(service: "shouldRemember", account: "Artemis"),
              String(data: rememberData, encoding: .utf8) == "true",
              let tokenData = KeychainHelper.shared.read(service: "isLoggedIn", account: "Artemis") else { return }
        isLoggedIn = String(data: tokenData, encoding: .utf8) == "true"
    }
    
    public func setUserLoggedIn(isLoggedIn: Bool, shouldRemember: Bool) {
        self.isLoggedIn = isLoggedIn
        let isLoggedInData = Data(isLoggedIn.description.utf8)
        let rememberData = Data(shouldRemember.description.utf8)
        KeychainHelper.shared.save(isLoggedInData, service: "isLoggedIn", account: "Artemis")
        KeychainHelper.shared.save(rememberData, service: "shouldRemember", account: "Artemis")
    }
}
