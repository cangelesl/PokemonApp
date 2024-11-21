//
//  SplashViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 19/11/24.
//

import UIKit

class SplashViewController: UIViewController {
    
    // Texto
    private let titleSplah: UILabel = {
        let titleSplah = UILabel()
       // titleSplah.text = "...Cargando Pokemón"
        titleSplah.font = UIFont.boldSystemFont(ofSize: 20)
        titleSplah.textColor = .blue
        titleSplah.textAlignment = .center
        return titleSplah
    }()
    
    // Imagen
    private let imageSplash: UIImageView = {
        let imageSplash = UIImageView()
        imageSplash.image = UIImage(named: "imageSplash")
        imageSplash.contentMode = .scaleAspectFit
        return imageSplash
    }()
    
    // Texto display
    private var textToDisplay: String = "...Cargando Pokemón"
    private var index = 0
    private var timer: Timer?
    
    // Indicador de carga
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadTextSplash()
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubview(imageSplash)
        view.addSubview(titleSplah)
        view.addSubview(activityIndicator)
        imageSplash.translatesAutoresizingMaskIntoConstraints = false
        titleSplah.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSplash.widthAnchor.constraint(equalToConstant: 300),
            imageSplash.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageSplash.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleSplah.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            titleSplah.topAnchor.constraint(equalTo: imageSplash.bottomAnchor, constant: 100)
        ])
    }
    
    private func loadTextSplash() {
        // Inicia un timer con un intervalo que se vaya ejecutando hasta que se culmine de recorrer la cadena
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.index < self.textToDisplay.count {
                let endIndex = self.textToDisplay.index(self.textToDisplay.startIndex, offsetBy: self.index + 1)
                let substring = String(self.textToDisplay[..<endIndex])
                self.titleSplah.text = substring
                self.index += 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}
