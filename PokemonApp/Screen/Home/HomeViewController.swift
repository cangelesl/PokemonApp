//
//  ViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 18/11/24.
//

import UIKit
import Networking

class HomeViewController: UIViewController {
    protocol HomeView {
        func setListPokemon(value: String)
    }
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        view.backgroundColor = .red
        Task {
            await viewModel.getListPokemon()
        }
        navigationItem.hidesBackButton = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  viewModel.listPokemon()
    }

}
