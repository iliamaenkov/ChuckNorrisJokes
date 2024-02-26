//
//  DataBaseService.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 22.02.2024.
//

import UIKit
import Foundation
import RealmSwift

final class DatabaseService {
    
    var tabBarController: UITabBarController?
    static let shared = DatabaseService()
    private var realm: Realm
    
    private init() {
        let config = Realm.Configuration(
            schemaVersion: 1
        )
        Realm.Configuration.defaultConfiguration = config
        self.realm = try! Realm()
    }
    
//MARK: Add Joke
    
    func addJoke(jokeResponse: JokeResponse) {
        guard let jokeId = jokeResponse.id else {
            print("Joke ID not found")
            return
        }
        
        if jokeExistsWithIdApi(jokeId) {
            print("Joke with idApi \(jokeId) already exsist")
            return
        }
        
        DispatchQueue.main.async {
            try! self.realm.write {
                var categoriesToAdd: [Category] = []
                
                if let categoryNames = jokeResponse.categories, !categoryNames.isEmpty {
                    categoriesToAdd = self.getCategoriesFromNames(categoryNames)
                } else {
                    if let existingCategory = self.realm.objects(Category.self).filter("name = %@", "No category").first {
                        categoriesToAdd.append(existingCategory)
                    } else {
                        let defaultCategory = Category()
                        defaultCategory.name = "No category"
                        categoriesToAdd.append(defaultCategory)
                    }
                }
                let newJoke = Joke()
                newJoke.idApi = jokeId
                
                newJoke.createdAt = self.dateFromString(jokeResponse.createdAt)
                newJoke.value = jokeResponse.value ?? ""

                for category in categoriesToAdd {
                    if let existingCategory = self.realm.objects(Category.self).filter("name = %@", category.name).first {
                        existingCategory.jokes.append(newJoke)
                        self.realm.add(existingCategory, update: .modified)
                    } else {
                        category.jokes.append(newJoke)
                        self.realm.add(category)
                    }
                    newJoke.categories.append(category)
                }
                self.realm.add(newJoke)
            }
        }
        updateJokesBadge()
    }
    
//MARK: Find joke
    
    private func jokeExistsWithIdApi(_ idApi: String) -> Bool {
        let existingJoke = realm.objects(Joke.self).filter("idApi = %@", idApi).first

        return existingJoke != nil
    }
    
    private func dateFromString(_ dateString: String?) -> Date {
        guard let dateString = dateString else { return Date() }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS" // Формат даты из jokeResponse.createdAt
        
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    private func getCategoriesFromNames(_ categoryNames: [String]) -> [Category] {
        var categories: [Category] = []
        for categoryName in categoryNames {
            if let existingCategory = realm.objects(Category.self).filter("name = %@", categoryName).first {
                categories.append(existingCategory)
            } else {
                let newCategory = Category()
                newCategory.name = categoryName
                realm.add(newCategory)
                categories.append(newCategory)
            }
        }
        return categories
    }
    
//MARK: Get all jokes
    
    func getAllJokes() -> [Joke] {
        let jokes = realm.objects(Joke.self).sorted(byKeyPath: "createdAt", ascending: false)
        
        return Array(jokes)
    }

    func getJokesForCategory(_ categoryName: String) -> [Joke] {
        if let category = realm.objects(Category.self).filter("name = %@", categoryName).first {
            return Array(category.jokes)
        } else {
            print("Category '\(categoryName)' not found")
            return []
        }
    }
    
//MARK: Get all categories
    
    func getAllCategories() -> [Category] {
        let categories = realm.objects(Category.self)
        return Array(categories)
    }
    
//MARK: Delete all jokes
    
    func deleteAllJokes() {
        DispatchQueue.main.async {
            try! self.realm.write {
                // Удаление всех объектов Joke и Category из Realm
                self.realm.deleteAll()
            }
        }
    }
    
//MARK: TotalJokeCount
    
    func getTotalJokesCount() -> Int {
        let totalJokes = realm.objects(Joke.self).count
        return totalJokes
    }
    
    //MARK: - Update badges
    
    func updateJokesBadge() {
        if let jokesTabBarItem = tabBarController?.tabBar.items?[1] {
            jokesTabBarItem.badgeValue = "New"
        }
    }
}
