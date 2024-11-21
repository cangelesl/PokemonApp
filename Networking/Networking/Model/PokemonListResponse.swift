//
//  PokemonListResponse.swift
//  Networking
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import Foundation

public struct PokemonListResponse: Decodable {
    
    public let count: Int
    public let results: [Pokemon]
    
}
public struct Pokemon: Decodable {
    
    public let name: String
    public let url: String
    
}
