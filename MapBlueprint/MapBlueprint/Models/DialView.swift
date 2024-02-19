//
//  DialView.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation
import UIKit

class DialView: UIView {
    var valueLabel: UILabel
    var iconImageView: UIImageView
    var titleLabel: UILabel

    init(value: Double, title: String, icon: UIImage) {
        valueLabel = UILabel()
        titleLabel = UILabel()
        iconImageView = UIImageView(image: icon)

        super.init(frame: .zero)
        
        setupViews()
        
        valueLabel.text = "\(value)"
        titleLabel.text = title
        iconImageView.image = icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        valueLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(valueLabel)
        addSubview(titleLabel)
        addSubview(iconImageView)
        
        // Define constraints for layout
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            

            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
    
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func alterImage(image: UIImage) {
        self.iconImageView = UIImageView(image: image)
    }

}
