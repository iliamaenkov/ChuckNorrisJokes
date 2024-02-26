//
//  JokeListViewController.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 22.02.2024.
//

import UIKit

final class JokeListVC: UIViewController {
    
    //MARK: - Properties/Init
    
    private let tableView = UITableView()
    private let category: Category?
    private var jokes: [Joke] = []
    private var isTabBarSelected: Bool = false

    init(category: Category?, isTabBarSelected: Bool = false) {
        self.category = category
        self.isTabBarSelected = isTabBarSelected
        super.init(nibName: nil, bundle: nil)
        title = category?.name ?? "Most fun"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !jokes.isEmpty {
            tableView.separatorStyle = .none
        }
        loadJokes()
        tabBarItem?.badgeValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRightBarButtonItem()
        loadJokes()
    }
    
    //MARK: - Private
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JokeTableViewCell.self, forCellReuseIdentifier: JokeTableViewCell.reuseIdentifier)
        tableView.register(JokeTableViewCell.self, forCellReuseIdentifier: "NoJokeCell")
    }
    
    private func loadJokes() {
        if let categoryName = category?.name {
            jokes = DatabaseService.shared.getJokesForCategory(categoryName)
        } else {
            jokes = DatabaseService.shared.getAllJokes()
        }
        tableView.reloadData()
    }
    
    private func setupRightBarButtonItem() {
        if isTabBarSelected {
            let deleteAllButton = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllJokes))
            navigationItem.rightBarButtonItem = deleteAllButton
        }
    }

    @objc private func deleteAllJokes() {
        let alertController = UIAlertController(title: "Delete All Jokes", message: "Are you sure you want to delete all jokes?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeleteAllJokes()
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func performDeleteAllJokes() {
        DatabaseService.shared.deleteAllJokes()
        jokes.removeAll()
        tableView.reloadData()
    }
}

//MARK: - Extensions

extension JokeListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        jokes.isEmpty ? 1 : jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if jokes.isEmpty {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoJokeCell")
            cell.textLabel?.text = "No jokes..."
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: JokeTableViewCell.reuseIdentifier, for: indexPath) as! JokeTableViewCell
            let joke = jokes[indexPath.row]
            cell.configure(with: joke, hideCatecory: category != nil)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if jokes.isEmpty {
            
            let jokeVC = LoadJokeVC()
            
            jokeVC.jokeAddedHandler = { [weak self] in

                self?.tableView.separatorStyle = .none
                self?.loadJokes()
                
            }
            
            let navController = UINavigationController(rootViewController: jokeVC)
            present(navController, animated: true, completion: nil)
        }
    }
}
