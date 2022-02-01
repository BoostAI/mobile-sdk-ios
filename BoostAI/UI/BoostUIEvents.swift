//
//  EventNotificationCenter.swift
//  BoostAI
//
//  Created by Bjornar.Tollaksen on 07/01/2022.
//  Copyright © 2022 boost.ai. All rights reserved.
//

import Foundation

open class BoostUIEvents {
    public static let shared = BoostUIEvents()
    
    public enum Event: String {
        case
        chatPanelOpened,
        chatPanelClosed,
        chatPanelMinimized,
        conversationIdChanged,
        messageSent,
        menuOpened,
        menuClosed,
        privacyPolicyOpened,
        conversationDownloaded,
        conversationDeleted,
        positiveMessageFeedbackGiven,
        negativeMessageFeedbackGiven,
        positiveConversationFeedbackGiven,
        negativeConversationFeedbackGiven,
        conversationFeedbackTextGiven,
        actionLinkClicked,
        externalLinkClicked,
        conversationReferenceChanged,
        filterValuesChanged
    }
    
    private var observers = [UUID : (Event, Any?) -> Void]()
    
    @discardableResult
    public func addEventObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (Event, Any?) -> Void
    ) -> ObservationToken {
        let id = UUID()
        
        observers[id] = { [weak self, weak observer] event, detail in
            
            guard observer != nil else {
                self?.observers.removeValue(forKey: id)
                return
            }
            
            closure(event, detail)
        }
        
        return ObservationToken { [weak self] in
            self?.observers.removeValue(forKey: id)
        }
    }
    
    public func publishEvent(event: Event, detail: Any? = nil) {
        observers.values.forEach { closure in
            closure(event, detail)
        }
    }
}
