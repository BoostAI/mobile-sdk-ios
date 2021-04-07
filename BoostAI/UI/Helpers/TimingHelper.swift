//
//  TimingHelper.swift
//  BoostAI
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import Foundation

struct TimingHelper {
    
    static let baseStaggerDelay: TimeInterval = 0.15
    static let defaultDelay: TimeInterval = 1.5
    
    static func calculatePace(_ pace: String) -> TimeInterval {
        switch pace {
        case "glacial":
            return 0.333
        case "slower":
            return 0.5
        case "slow":
            return 0.8
        case "normal":
            return 1
        case "fast":
            return 1.25
        case "faster":
            return 2
        case "supersonic":
            return 3;
        default:
            return 1
        }
    }
    
    static func calculateStaggerDelay(pace: String, idx: Int) -> TimeInterval {
        let delay = baseStaggerDelay * TimeInterval(idx);
        let multiplier = calculatePace(pace);
        return delay / multiplier;
    }
    
    static func calcTimeToRead(pace: TimeInterval) -> TimeInterval {
        return defaultDelay / pace
    }
}
