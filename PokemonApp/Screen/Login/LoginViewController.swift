//
//  LoginViewController.swift
//  PokemonApp
//
//  Created by Carlos Gerald Angeles La Torre on 20/11/24.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    // Login imagen
    private let imageBackgroundLogin: UIImageView = {
        let imageLogin = UIImageView()
        imageLogin.image = UIImage(named: "imageBackgroundLogin")
        imageLogin.contentMode = .scaleAspectFit
        imageLogin.translatesAutoresizingMaskIntoConstraints = false
        return imageLogin
    }()
    
    // Imagen
    private let imageLogin: UIImageView = {
        let imageLogin = UIImageView()
        imageLogin.image = UIImage(named: "ImageLogin")
        imageLogin.contentMode = .scaleAspectFit
        imageLogin.translatesAutoresizingMaskIntoConstraints = false
        return imageLogin
    }()
    
    // Texto
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Boton
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // view.backgroundColor = .white
        setup()
        
    }
    func setup(){
        // Add
        view.addSubview(imageBackgroundLogin)
        view.addSubview(imageLogin)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        // Constraints
        NSLayoutConstraint.activate([
            imageBackgroundLogin.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageBackgroundLogin.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageBackgroundLogin.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageBackgroundLogin.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageLogin.widthAnchor.constraint(equalToConstant: 600),
            imageLogin.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: imageLogin.bottomAnchor, constant: 10),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        loginButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
   /*
    @objc func buttonTapped(sender: UIButton) {
        navigationController?.pushViewController(HomeViewController(viewModel: HomeViewModel()), animated: true)
    }
     */
  
    private let loginModel: LoginViewModel
    
    @objc func buttonTapped(sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        Task {
              do {
                  try await loginModel.login(with: username, password: password)
                  // Navegar a la siguiente pantalla en caso de éxito
                  let homeViewController = HomeViewController(viewModel: HomeViewModel())
                  navigationController?.pushViewController(homeViewController,
       animated: true)
              } catch {
                  // Manejar el error
                  print("Error de inicio de sesión: \(error)")
              }
          }
    }

    
}



