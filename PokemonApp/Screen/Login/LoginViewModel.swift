//
//  LoginViewModel.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 20/11/24.
//

import Foundation
import Networking

final class LoginViewModel{
    let networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
    }

    func login(with user: String, password: String) async {
        let loginRequest = LoginRequest(user: user, password: password)
        Task {
            let loginResult: Result<LoginResponse, Error> = await networkingManager.login(with: loginRequest)
            // Manejar el resultado del login
            switch loginResult {
            case .success(let login):
                print(login)
            case .failure(let error):
                // Manejar el error
                print(error)
            }
        }
    }
    
    
    
}
