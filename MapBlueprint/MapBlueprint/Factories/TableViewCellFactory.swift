//
//  TableViewCellFactory.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation

import UIKit

protocol TableViewCellFactoryType {
    func styleCell(cell: UITableViewCell, tableOption: TableOption) -> UITableViewCell
    
    func styleCell(cell: UITableViewCell, label: String) -> UITableViewCell
}

/// This File ensures that we have a common type of cell across the app, and to reduce redundant code
class TableViewCellFactory: TableViewCellFactoryType {
    func styleCell(cell: UITableViewCell, tableOption: TableOption) -> UITableViewCell {
        cell.textLabel?.text = tableOption.text
        cell.imageView?.image = UIImage(systemName: tableOption.image)

        cell.selectionStyle = .none
        cell.textLabel?.textColor = .label // Adapts to light/dark mode
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
        
        return cell
    }
    func styleCell(cell: UITableViewCell, label: String) -> UITableViewCell {
        cell.textLabel?.text = label
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .label
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
        
        return cell
    }
}
