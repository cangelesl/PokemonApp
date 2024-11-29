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
    // Barra de busqueda
    private let searchBar : UISearchBar = {
        // Agregar la barra de búsqueda
        let searchBar = UISearchBar()
        searchBar.placeholder = "Buscar Pokémon"
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.barStyle = .default
        return searchBar
    }()
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
        // searchBar
        searchBar.delegate = self
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

    // se usa la propiedad didselectrowat para capturar la seleccion, invocar la función detail view model y actualizar el dtailview controller
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
        // Configuración de la celda con el modelo de datos
        cell.configure(with: pokemon)
        // Configurar el comportamiento del botón de favorito
        cell.onFavoriteToggle = { [weak self] in // weak self evita la referencia ciclica y que crashee en caso no exista el homeviewmodel
            guard let self = self else { return }
            self.viewModel.toggleFavorite(at: indexPath.row, isFiltered: !self.viewModel.searchText.isEmpty)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
     }
    
    
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
    let pokemonImageView : UIImageView = {
        // Se define la configuración de la imagen en la celda
        let pokemonImageView = UIImageView()
        pokemonImageView.contentMode = .scaleAspectFit
        return pokemonImageView
    }()
    let pokemonNameLabel : UILabel = {
        // Se configura el label con el nombre del pokemon
        let pokemonNameLabel = UILabel()
        pokemonNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return pokemonNameLabel
    }()
    // Definir botón en forma de estrella, para favoritos
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        return button
    }()
    // se crea un closure que no devuelva  nada (void)
    var onFavoriteToggle: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Se agregan los componentes a la celda
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(pokemonNameLabel)
        contentView.addSubview(favoriteButton)
        pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
        pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Se define la imagen con tamaño fijo
            pokemonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            pokemonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 50),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 50),
            // Se define el nombre a la derecga
            pokemonNameLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 10),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            pokemonNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            // Se define el botón de favoritos
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    @objc private func favoriteButtonTapped() {
        onFavoriteToggle?() // Se llama al closure
    }
    
    func configure(with pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.name.capitalized
        //print(pokemon.isFavorite)
        let buttonImage = pokemon.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favoriteButton.setImage(buttonImage, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



