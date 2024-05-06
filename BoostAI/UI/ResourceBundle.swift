//
//  ResourceBundle.swift
//  BoostAI
//
//  Created by Bjørnar Tollaksen on 06/05/2024.
//  Copyright © 2024 boost.ai. All rights reserved.
//

import Foundation

final class ResourceBundle {
    static let bundle: Bundle = {
        let myBundle = Bundle(for: ResourceBundle.self)

        guard let bundleURL = myBundle.url(
            forResource: "BoostAI-Resources", withExtension: "bundle"
        )
        else {
            return myBundle
        }

        guard let bundle = Bundle(url: bundleURL)
        else { fatalError("Cannot access BoostAI-Pod-Resources!") }

        return bundle
    }()
}
