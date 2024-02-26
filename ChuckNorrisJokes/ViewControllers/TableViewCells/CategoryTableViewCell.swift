//
//  CategoryTableViewCell.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 22.02.2024.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "CategoryCell"
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        detailTextLabel?.textColor = .gray
    }
}
