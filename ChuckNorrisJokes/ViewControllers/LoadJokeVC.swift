//
//  LoadJokeViewController.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 22.02.2024.
//

import UIKit

final class LoadJokeVC: UIViewController {
    
    //MARK: - Properties
    
    private lazy var addJoke = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadJokeButtonTapped))
    var jokeAddedHandler: (() -> Void)?
    
    let networkService = NetworkService.shared
    let databaseService = DatabaseService.shared
    
    //MARK: - UI
    
    let jokeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        navigationItem.title = "New Joke"
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = addJoke
    }
    
    //MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(jokeLabel)
        view.addSubview(categoryLabel)
        view.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            jokeLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            jokeLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -100),
            jokeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            jokeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: jokeLabel.bottomAnchor, constant: 20),
            categoryLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 5),
            dateLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    @objc private func loadJokeButtonTapped() {
        activityIndicator.startAnimating()
        addJoke.isEnabled = false
        
        networkService.loadRandomJoke { [weak self] jokeResponse, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.addJoke.isEnabled = true
            }
            
            if let error = error {
                print("Error loading joke: \(error.localizedDescription)")
                return
            }
            
            guard let jokeResponse = jokeResponse else {
                print("No joke response received")
                return
            }
            
            self.databaseService.addJoke(jokeResponse: jokeResponse)
            
            DispatchQueue.main.async {
                self.jokeLabel.text = jokeResponse.value
                self.categoryLabel.text = "Category: \(jokeResponse.categories?.joined(separator: ", ") ?? "No category")"
                self.dateLabel.text = "Date: \(jokeResponse.createdAt ?? "No date")"
                
                self.jokeAddedHandler?()
            }
        }
    }
}
