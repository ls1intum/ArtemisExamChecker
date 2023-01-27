//
//  File.swift
//  
//
//  Created by Sven Andabaka on 26.01.23.
//

import Foundation

public struct UserFacingError: Codable {
    public var title: String
    public var status: Int? = nil
    public var detail: String? = nil
    public var message: String? = nil
    public var path: String? = nil
    public var code: String? = nil
    public var type: URL? = nil
    
    public var description: String {
        return detail ?? message ?? title
    }
    
    public init(error: Error) {
        title = error.localizedDescription
    }
}
