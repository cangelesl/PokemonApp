//
//  PokemonListResponse.swift
//  Networking
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import Foundation

public struct PokemonListResponse: Decodable {
    
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [Pokemon]
    
}
public struct Pokemon: Decodable {
    
    public let name: String
    public let url: String
    
    // Inicializador
    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
