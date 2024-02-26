//
//  JokeResponse.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 26.02.2024.
//

import UIKit

struct JokeResponse: Decodable {
    let categories: [String]?
    let created_at: String?
    let id: String?
    let value: String?
    
    var createdAt: String? {
        return created_at
    }
}
