//
//  DetailViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 26/11/24.
//

import UIKit
import Combine
import Kingfisher
import Networking

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let nameLabel = UILabel()
    private let weightLabel = UILabel()
    private let heightLabel = UILabel()
    private let pokemonImageView = UIImageView()
    private let shinySwitch = UISwitch() // Switch para cambiar entre imagen normal y shiny
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindViewModel()
        fetchPokemonDetails()
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(nameLabel)
        view.addSubview(weightLabel)
        view.addSubview(heightLabel)
        view.addSubview(pokemonImageView)
        view.addSubview(shinySwitch)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        shinySwitch.translatesAutoresizingMaskIntoConstraints = false
        // Configuración del Switch
        shinySwitch.addTarget(self, action: #selector(didToggleShinySwitch), for: .valueChanged)
        NSLayoutConstraint.activate([
            // Nombre del Pokémon
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            // Imagen del Pokémon
            pokemonImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            pokemonImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 150),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 150),
            // Switch
            shinySwitch.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            shinySwitch.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            // Descripción (peso y altura)
            weightLabel.topAnchor.constraint(equalTo: shinySwitch.bottomAnchor, constant: 20),
            weightLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            weightLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            weightLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            heightLabel.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 20),
            heightLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            heightLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            heightLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            
        ])
    }
    
    private func bindViewModel() {
        viewModel.$pokemonDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self else { return }
                self.updateUI(with: detail)
            }
            .store(in: &cancellables)
    }
    
    private func fetchPokemonDetails() {
        Task {
            await viewModel.getDetailPokemon()
        }
    }
    
    private func updateUI(with detail: PokemonDetailResponse?) {
        guard let detail = detail else { return }
        nameLabel.text = detail.name.capitalized
        
        // Mostrar imagen normal inicialmente
        updateImage(shiny: false)
        
        // Actualizar descripción con peso y altura
        let weight = Double(detail.weight)
        let height = Double(detail.height)
        weightLabel.text = "Peso: \(weight)"
        heightLabel.text = "Altura: \(height)"
        weightLabel.textAlignment = .center
        heightLabel.textAlignment = .center
    }
    
    private func updateImage(shiny: Bool) {
        guard let detail = viewModel.pokemonDetail else { return }
        let imageUrlString = shiny ? detail.sprites.frontShiny : detail.sprites.frontDefault
        if let urlString = imageUrlString, let url = URL(string: urlString) {
            pokemonImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"), options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ])
        }
    }
    
    @objc private func didToggleShinySwitch(_ sender: UISwitch) {
        updateImage(shiny: sender.isOn)
    }
}
