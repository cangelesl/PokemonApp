//
//  LoginResponse.swift
//  Networking
//
//  Created by Carlos Gerald Angeles La Torre on 21/11/24.
//

import Foundation

// MARK: - LoginResponse
public struct LoginResponse: Decodable {
    public  let user, password, name, lastName: String?
    public let correo: String?
    public let result: String
    
    enum CodingKeys: String, CodingKey {
        case user, password, name
        case lastName = "last_name"
        case correo
        case result = "Result"
    }
}

// MARK: - LoginResponse
public struct LoginRequest: Encodable {
    public let user: String
    public let password: String
    
    public init(user: String, password: String) {
        self.user = user
        self.password = password
    }
}
