//
//  JokeRealm.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 26.02.2024.
//

import UIKit
import RealmSwift

final class Joke: Object {
    @Persisted(primaryKey: false) var id = UUID().uuidString
    @Persisted var idApi: String = ""
    @Persisted var createdAt: Date
    @Persisted var value: String = ""
    @Persisted var categories = List<Category>()
}

final class Category: Object {
    @Persisted(primaryKey: true) var name: String = ""
    @Persisted var jokes = List<Joke>()
}
