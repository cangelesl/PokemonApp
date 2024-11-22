//
//  ViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 18/11/24.
//

import UIKit
import Networking

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private let tableView = UITableView()
    
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
        fetchInitialData()
    }
    private func setup() {
        view.backgroundColor = .red
        title = "Lista de Pokemones"
        // Definir los atributos del titulo (bold y color)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20), // Título en negrita
            .foregroundColor: UIColor.white // Color blanco
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PokemonCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func fetchInitialData() {
        Task {
            await viewModel.getListPokemon()
            tableView.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        let pokemon = viewModel.pokemons[indexPath.row]
        cell.textLabel?.text = pokemon.name.capitalized
        return cell
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
