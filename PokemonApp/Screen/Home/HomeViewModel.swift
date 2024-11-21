//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import Foundation
import Networking

final class HomeViewModel{
    let networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
    }
  
    func getListPokemon() async {
        Task {
            let pokemonListResult: Result<PokemonListResponse, Error> = await networkingManager.listPokemon(url: "https://pokeapi.co/api/v2/pokemon?limit=20")
            // Manejar el resultado (éxito o error)
            switch pokemonListResult {
            case .success(let pokemonList):
                // Extraer la lista de Pokemon del resultado exitoso
                print(pokemonList)
            case .failure(let error):
                // Manejar el error
                print(error)
            }
        }
    }
    
    
    
}
