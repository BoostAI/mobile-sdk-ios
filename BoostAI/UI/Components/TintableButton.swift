//
//  TintableButton.swift
//  BoostAI
//
//  Created by Bjornar.Tollaksen on 27/01/2022.
//  Copyright © 2022 boost.ai. All rights reserved.
//

import UIKit

public class TintableButton: UIButton {
    
    public enum ButtonState {
        case normal
        case disabled
    }
    
    private var disabledTintColor: UIColor?
    private var defaultTintColor: UIColor? {
        didSet {
            tintColor = defaultTintColor
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultTintColor {
                    self.tintColor = color
                }
            }
            else {
                if let color = disabledTintColor {
                    self.tintColor = color
                }
            }
        }
    }

    public func setTintColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledTintColor = color
        case .normal:
            defaultTintColor = color
        }
    }

}
