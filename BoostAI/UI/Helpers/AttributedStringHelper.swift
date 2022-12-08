//
//  AttributedStringHelper.swift
//  BoostAI
//
//  Created by Bjornar.Tollaksen on 06/12/2022.
//  Copyright © 2022 boost.ai. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func trimmedAttributedString() -> NSAttributedString {
        let nonNewlines = CharacterSet.whitespacesAndNewlines.inverted
        // 1
        let startRange = string.rangeOfCharacter(from: nonNewlines)
        // 2
        let endRange = string.rangeOfCharacter(from: nonNewlines, options: .backwards)
        guard let startLocation = startRange?.lowerBound, let endLocation = endRange?.lowerBound else {
            return self
        }
        // 3
        let range = NSRange(startLocation...endLocation, in: string)
        return attributedSubstring(from: range)
    }
}
