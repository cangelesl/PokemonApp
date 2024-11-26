//
//  DetailViewModel.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 26/11/24.
//

import Foundation
import Networking
import Combine

final class DetailViewModel: ObservableObject {
    @Published var pokemonDetail: PokemonDetailResponse? // Observable
    private let networkingManager: NetworkingManager
    var name: String?

    init(networkingManager: NetworkingManager = NetworkingManager.shared) {
        self.networkingManager = networkingManager
    }
    
    func getDetailPokemon() async {
        guard let name = name else { return }
        do {
            // Realiza la solicitud a la API
            let result: Result<PokemonDetailResponse, Error> = await networkingManager.pokemonDetail(name: name)
            // Procesa el resultado
            switch result {
            case .success(let response):
                pokemonDetail = response
                print("Pokemon Detail Fetched Successfully: \(response)")
            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }
    }
}
