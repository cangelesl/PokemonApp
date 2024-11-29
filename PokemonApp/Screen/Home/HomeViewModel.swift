//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import Foundation
import Networking
import Combine

final class HomeViewModel{
    let networkingManager: NetworkingManager
    // Variables de lectura del json
    private(set) var pokemons: [Pokemon] = [] // Lista de pokemon del modelo
    @Published var filteredPokemon: [Pokemon] = []
    // Combine
    @Published var searchText: String = "" // Texto del UISearchBar
    private var cancellables = Set<AnyCancellable>()
    private var nextURL: String? = "https://pokeapi.co/api/v2/pokemon?limit=20"// URL para proximo envio,opcional
    private var isLoading = false // Controla solicitud y evita solicitudes simultaneas
    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
        //Espera Cambios del searchText
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Retraso para evitar búsquedas excesivas
            .removeDuplicates()
            .sink { [weak self] text in
                Task {
                    await self?.searchPokemon(by: text)
                }
            }
            .store(in: &cancellables)
    }
    
    func getListPokemon() async {
        // Se valida que no haya una carga en curso y que haya URL disponible
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
                filteredPokemon = pokemons // actualiza el array de pokemon
                print(pokemons)
                nextURL = response.next // setea nuevo next url
            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }

        isLoading = false
    }
    
    func searchPokemon(by name: String) async {
        guard !name.isEmpty else {
            filteredPokemon = pokemons // Mostrar todos si el campo está vacío
            return
        }

        do {
            let result: Result<PokemonDetailResponse, Error> = await networkingManager.pokemonDetail(name: name.lowercased())
            switch result {
            case .success(let pokemonDetail):
                // Convierte PokemonDetailResponse a un modelo compatible con la lista
                let pokemon = Pokemon(name: pokemonDetail.name, url:"https://pokeapi.co/api/v2/pokemon/\(pokemonDetail.id)")
                filteredPokemon = [pokemon]	
            case .failure:
                filteredPokemon = [] // Vaciar la lista si no se encuentra
            }
        } catch {
            print("Error buscando Pokémon: \(error)")
            filteredPokemon = [] // Vaciar la lista si ocurre un error
        }
    }

    
}
extension HomeViewModel {
    func toggleFavorite(at index: Int, isFiltered: Bool) {
        if isFiltered {
            // Se cambia el valor de isFavorite en filteredPokemon
            filteredPokemon[index].isFavorite.toggle()
            let name = filteredPokemon[index].name
            if let originalIndex = pokemons.firstIndex(where: { $0.name == name }) {
                pokemons[originalIndex].isFavorite = filteredPokemon[index].isFavorite
            }
        } else {
            pokemons[index].isFavorite.toggle()
            // Se actualiza también los pokemones filtrados
            if let filteredIndex = filteredPokemon.firstIndex(where: { $0.name == pokemons[index].name }) {
                filteredPokemon[filteredIndex].isFavorite = pokemons[index].isFavorite
            }
        }
    }
}
