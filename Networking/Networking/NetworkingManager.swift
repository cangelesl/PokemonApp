//
//  NetworkingManager.swift
//  Networking
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import Foundation
import Alamofire


    // Blueprint -----> Plano de contruccion -- Define método y propiedades
public protocol NetworkingManagerRepresentable {
    func listPokemon<PokemonListResponse: Decodable>(url: String) async -> Result<PokemonListResponse, Error>
    func login(with request: LoginRequest) async -> Result<LoginResponse, Error>

}
    
public class NetworkingManager: NetworkingManagerRepresentable {
    
    public static let shared = NetworkingManager()
    
    public func listPokemon<PokemonListResponse: Decodable>(url: String) async -> Result<PokemonListResponse, Error>{
        let response = await AF.request(url)
        // Validate response code and Content-Type.
            .validate()
        // Automatic Decodable support with background parsing.
            .serializingDecodable(PokemonListResponse.self)
        // Await the full response with metrics and a parsed body.
            .response
        print(response.result)
        print(response.result)
        switch response.result {
        case .success(let response):
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func login<LoginResponse: Decodable>(with request: LoginRequest) async -> Result<LoginResponse, Error> {
            let response = await AF.request("http://localhost:3000/login",
                                                method: .post,
                                                parameters: request,
                                                encoder: JSONParameterEncoder.default)
                                                .validate()
                                                .serializingDecodable(LoginResponse.self)

        print(response)
        switch await response.result {
        case .success(let response):
            return .success(response)
        case .failure(let error):
            return .failure(error)
            
        }

    }
}
