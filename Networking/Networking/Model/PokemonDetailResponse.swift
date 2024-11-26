//
//  PokemonDetail.swift
//  Networking
//
//  Created by Carlos Gerald Angeles La Torre on 25/11/24.
//

import Foundation

public struct PokemonDetailResponse: Decodable {
    public let id: Int
    public let name: String
    public let weight: Int
    public let height: Int
    public let order: Int
    public let sprites: Sprites
    public let types: [TypeElement]

    enum CodingKeys: String, CodingKey {
        case id, name, weight, height, order, sprites, types
    }
}

public struct Sprites: Decodable {
    public let frontDefault: String?
    public let frontShiny: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}

public struct TypeElement: Decodable {
    public let slot: Int
    public let type: Type

    enum CodingKeys: String, CodingKey {
        case slot, type
    }
}

public struct Type: Decodable {
    public let name: String
    public let url: String
}
