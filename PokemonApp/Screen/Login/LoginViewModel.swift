//
//  LoginViewModel.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 20/11/24.
//

import Foundation
import Networking

final class LoginViewModel {
    let networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
    }

    func login(with user: String, password: String) async throws{
        let loginRequest = LoginRequest(user: user, password: password)
            let loginResult: Result<LoginResponse, Error> = try await networkingManager.login(with: loginRequest)
            switch loginResult {
            case .success(let response):
                if response.result != "Success" {
                    throw LoginError.invalidCredentials
                }
                // Guardar usuario en user defaults
                UserDefaults.standard.set(user, forKey: "lastLoggedUser")
            case .failure(let error):
                throw error
            }
    }
    
    // Define función para recuperar el usuario guardado
    func getLastLoggedUser() -> String? {
        return UserDefaults.standard.string(forKey: "lastLoggedUser")
    }

    
}
//Definir error por inicio de sesión
enum LoginError: Error {
    case invalidCredentials
}
