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
    // Variables de lectura del json
    private(set) var pokemons: [Pokemon] = [] // Lista de pokemon del modelo
    private var nextURL: String? = "https://pokeapi.co/api/v2/pokemon?limit=20"// URL para proximo envio,opcional
    private var isLoading = false // Controla solicitud y evita solicitudes simultaneas
    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
    }
    
    func getListPokemon() async {
        // Validamos que no haya una carga en curso y que haya URL disponible
        guard !isLoading, let url = nextURL else { return }
        isLoading = true
        do {
            // Realiza la solicitud a la API
            let result: Result<PokemonListResponse, Error> = await networkingManager.listPokemon(url: url)
            // Procesa el resultado
            switch result {
            case .success(let response):
                // llena la lista de pokemons
                pokemons.append(contentsOf: response.results)
                nextURL = response.next // setea nuevo next url
            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }

        isLoading = false
    }
}
