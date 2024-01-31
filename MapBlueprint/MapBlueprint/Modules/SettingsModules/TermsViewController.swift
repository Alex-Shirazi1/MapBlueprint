//
//  TermsViewController.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 1/31/24.
//

import Foundation
import UIKit

class TermsViewController: UIViewController {

    let termsOfService = "Terms of Service"
    let rickRoll = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley"

    let textView: UITextView = {
        let textView = UITextView()
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        var linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
            .underlineColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 24)
        ]

        if let validURL = NSURL(string: rickRoll) {
            linkAttributes[.link] = validURL
        }

        let linkAttributedString = NSAttributedString(string: termsOfService, attributes: linkAttributes)
        textView.attributedText = linkAttributedString
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            textView.heightAnchor.constraint(equalTo: textView.widthAnchor)
        ])
    }
}
