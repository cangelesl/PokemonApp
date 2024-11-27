//
//  ViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 18/11/24.
//

import UIKit
import Networking
import Kingfisher
import Combine

class HomeViewController: UIViewController, UISearchBarDelegate {
    private let viewModel: HomeViewModel
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setup()
        bindViewModel()
        fetchInitialData()
    }

    private func setup() {
        view.backgroundColor = .white
        title = "Lista de Pokemones"
        // Definir los atributos del título (bold y color)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        // Agregar la barra de búsqueda
        searchBar.placeholder = "Buscar Pokémon"
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.barStyle = .default
        // Registrar la celda personalizada
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        tableView.delegate = self
        tableView.dataSource = self
        // Agregar la tabla a la vista
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func fetchInitialData() {
        Task {
            await viewModel.getListPokemon()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.$filteredPokemon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
       
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           viewModel.searchText = ""
           searchBar.resignFirstResponder()
       }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPokemon.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as? PokemonCell else {
            return UITableViewCell()
        }
        let pokemon = viewModel.filteredPokemon[indexPath.row]
        cell.pokemonNameLabel.text = pokemon.name.capitalized
        // Construir la URL de la imagen del Pokémon
        if let pokemonID = Int(pokemon.url.split(separator: "/").last ?? "") {
             let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png"
             if let url = URL(string: imageUrl) {
                 cell.pokemonImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"), options: [
                     .transition(.fade(0.2)),
                     .cacheOriginalImage
                 ])
             }
         }
         return cell
     }
    // se usa la propiedad didselectrowat para capturar la seleccion, invocar la función detail view model y actualizar el dtailview controller
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Usar la lista filtrada si hay búsqueda activa, de lo contrario usar la lista completa
        let pokemonName: String
        if viewModel.searchText.isEmpty {
            pokemonName = viewModel.pokemons[indexPath.row].name
        } else {
            pokemonName = viewModel.filteredPokemon[indexPath.row].name
        }
        print(pokemonName)
        let detailViewModel = DetailViewModel()
        detailViewModel.name = pokemonName // Enviar nombre al detalle
        let detailVC = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.pokemons.count - 1 {
            Task {
                await viewModel.getListPokemon()
                tableView.reloadData()
            }
        }
    }
}
// Celda personalizada
class PokemonCell: UITableViewCell {
    let pokemonImageView = UIImageView()
    let pokemonNameLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configurar la vista de la imagen
        pokemonImageView.contentMode = .scaleAspectFit
        contentView.addSubview(pokemonImageView)
        // Configurar la etiqueta del nombre
        pokemonNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(pokemonNameLabel)
        // Agregar constraints para los elementos
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Imagen: a la izquierda con tamaño fijo
            pokemonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            pokemonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 50),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 50),
            // Nombre: a la derecha de la imagen y con margen
            pokemonNameLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 10),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            pokemonNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



