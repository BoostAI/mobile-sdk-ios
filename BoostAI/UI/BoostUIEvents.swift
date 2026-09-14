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
    
    /// Serializes access to the observer table. This is a process-wide singleton whose
    /// registration and cancellation are public API, so nothing stops a host from touching
    /// it off the main thread while an event publishes; unsynchronized Dictionary access
    /// from two threads is undefined behaviour. Mirrors `ChatBackend`'s observer handling.
    private let stateQueue = DispatchQueue(label: "ai.boost.BoostUIEvents.state")

    private var observers = [UUID : (Event, Any?) -> Void]()

    /// Register an observer for UI events.
    ///
    /// The entry is removed when the token is cancelled or when `observer` deallocates —
    /// but note that the closure is retained by this singleton until then, so capture
    /// `observer` weakly inside it (`[weak self]`); a strong capture keeps the observer
    /// alive forever and the entry is never cleaned up.
    @discardableResult
    public func addEventObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (Event, Any?) -> Void
    ) -> ObservationToken {
        let id = UUID()

        stateQueue.sync {
            observers[id] = { [weak self, weak observer] event, detail in

                guard observer != nil else {
                    self?.removeObserver(id: id)
                    return
                }

                closure(event, detail)
            }
        }

        return ObservationToken { [weak self] in
            self?.removeObserver(id: id)
        }
    }

    public func publishEvent(event: Event, detail: Any? = nil) {
        // Snapshot under the lock, invoke outside it, so an observer that cancels its token
        // or registers a new one from inside its own closure cannot deadlock.
        let observers = stateQueue.sync { Array(self.observers.values) }

        observers.forEach { closure in
            closure(event, detail)
        }
    }

    // Returns the removed closure so the caller releases it after the lock has been given
    // up; releasing it on the queue would run captured objects' deinits there, and a deinit
    // that cancels another token would deadlock on a nested sync.
    @discardableResult
    private func removeObserver(id: UUID) -> ((Event, Any?) -> Void)? {
        return stateQueue.sync { observers.removeValue(forKey: id) }
    }
}
