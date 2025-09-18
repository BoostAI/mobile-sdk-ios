//
//  Errors.swift
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

enum SDKError: LocalizedError {
    case tooLong(_ message: String)
    case noConversation(_ message: String)
    case response(_ message: String)
    case error(_ message: String)
    case data(_ message: String)
    case noUploadDefined(_ message: String)
    case serverUnavailable
    
    var errorDescription: String? {
        switch self {
        case let .tooLong(message),
             let .noConversation(message),
             let .response(message),
             let .error(message),
             let .data(message),
            let .noUploadDefined(message):
            return message
        case .serverUnavailable:
            return nil
        }
    }
}
