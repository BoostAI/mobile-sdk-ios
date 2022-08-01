//
//  ChatBackend.swift
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

fileprivate extension Dictionary where Key == UUID {
    mutating func insert(_ value: Value) -> UUID {
        let id = UUID()
        self[id] = value
        return id
    }
}


open class ChatBackend {
    public static let shared = ChatBackend()
    
    /// Domain of your chatbot. You need to set this to get the sdk to work. E.g: sdk.boost.ai. Do not use http(s) or url path in this. The SDK will add those
    public var domain: String = ""
    /// Provide a custom URLSession if needed
    public var urlSession: URLSession = URLSession.shared
    /// The conversation Id. If you store this for later usage, you need to set this instead of calling start()
    public var conversationId: String?
    /// User token. This is used instead of conversation id if set
    public var userToken: String?
    public var reference: String = ""
    public var customPayload: String? = nil
    public var fileUploadServiceEndpointUrl: String? = nil
    /// Set your preference for html or text response. This will be added to all calls supporting it. Default is html=false
    public var clean = false
    /// The current language of the bot
    public var languageCode: String = "no-NO"
    public var clientTimezone: String = "Europe/Oslo"
    public var preferredClientLanguages: [String] = []
    
    public var isBlocked = false
    public var allowDeleteConversation = false
    public var chatStatus: ChatStatus = ChatStatus.virtual_agent
    public var poll = false
    public var maxInputChars = 110
    public var privacyPolicyUrl = "https://www.boost.ai/privacy-policy"
    public var lastResponse: APIMessage?
    
    private var lastTyped: Date?
    
    public var pollInterval: TimeInterval = 2.5
    public var pollValue: String?
    private var pollTimer: Timer?
    
    private var messageObservers = [UUID : (ChatBackend, APIMessage?, Error?) -> Void]()
    private var configObservers = [UUID : (ChatBackend, ChatConfig?, Error?) -> Void]()
    private var eventObservers = [UUID : (ChatBackend, String, Any?) -> Void]()
    public var messages: [APIMessage] = []
    public var config: ChatConfig?
    public var vanId: Int? = nil
    public var filter: Filter?
    public var skill: String?
    
    public init() {
        
    }
}

/// Add url functions
extension ChatBackend {
    func getChatUrl() -> URL {
        return URL(string: "https://\(domain)/api/chat/v2")!
    }
    
    func getConfigUrl() -> URL {
        return URL(string: "https://\(domain)/api/chat_panel/v2")!
    }
}

/// Add functions which communicate with the API
extension ChatBackend {
    
    public func onReady(completion: @escaping (ChatConfig?, Error?) -> Void) {
        if let config = self.config {
            completion(config, nil)
            return
        }
        self.getConfig(completion: {
            config, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(config, nil)
        })
    }
    
    public func getConfig(completion: @escaping (ChatConfig?, Error?) -> Void) {
        var request = URLRequest(url: self.getConfigUrl())
        request.httpMethod = "POST" //set http method as POST
        var parameters = CommandConfig()
        if let vanId = self.vanId {
            parameters.vanId = vanId
        }
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(parameters)
            request.httpBody = jsonData
        } catch let error {
            completion(nil, error)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = urlSession.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            let decoder = JSONDecoder()
            let formatter = DateFormatter.iso8601Full
            decoder.dateDecodingStrategy = .formatted(formatter)
            do {
                let error = try decoder.decode(APIResponseError.self, from: data)
                throw SDKError.response(error.error)
            } catch _ {}
            do {
                
                let configV2: ConfigV2 = try decoder.decode(ConfigV2.self, from: data)
                let config = convertConfig(configV2: configV2)
                self.config = config
                
                completion(config, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        task.resume()
        
    }
    
    public func download(completion: @escaping (APIMessage?, Error?) -> Void) {
        var request = URLRequest(url: self.getChatUrl())
        request.httpMethod = "POST" //set http method as POST
        let parameters = CommandDownload(conversationId: self.conversationId, userToken: self.userToken)
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(parameters)
            request.httpBody = jsonData
        } catch let error {
            completion(nil, error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = urlSession.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let error = try decoder.decode(APIResponseError.self, from: data)
                completion(nil, SDKError.response(error.error))
            } catch _ {}
            let str = String(decoding: data, as: UTF8.self)
            let apiMessage = APIMessage(download: str)
            completion(apiMessage, nil)
        })
        task.resume()
    }
    
    public func post(parameters: Data, completion: @escaping (APIMessage?, Error?) -> Void) {
        
        var request = URLRequest(url: self.getChatUrl())
        request.httpMethod = "POST" //set http method as POST
        request.httpBody = parameters
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = urlSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            guard error == nil else {
                completion(nil, SDKError.error(error!.localizedDescription))
                return
            }
            
            guard let data = data else {
                completion(nil, SDKError.data("No data"))
                return
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter.iso8601Full
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode > 399 {
                do {
                    let apiError = try decoder.decode(APIResponseError.self, from: data)
                    throw SDKError.response(apiError.error)
                } catch {
                    if let _ = error as? SDKError {
                        completion(nil, error)
                        return
                    }
                }
                
                completion(nil, SDKError.response("An unknown error occured"))
                return
            }
           
            do {
                let apiMessage: APIMessage = try decoder.decode(APIMessage.self, from: data)
                try self?.handleApiMessage(apiMessage)
                completion(apiMessage, nil)
                
                self?.handleJsonEvent(apiMessage: apiMessage)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
    func handleApiMessage(_ apiMessage: APIMessage) throws {
        guard let conversation = apiMessage.conversation else {
            throw SDKError.noConversation("No conversation in response")
        }
        self.conversationId = conversation.id
        self.reference = conversation.reference ?? self.reference
        let state = conversation.state
        self.allowDeleteConversation = state.allowDeleteConversation ?? self.allowDeleteConversation
        self.chatStatus = state.chatStatus
        self.isBlocked = state.isBlocked ?? false
        self.maxInputChars = state.maxInputChars ?? self.maxInputChars
        self.lastResponse = apiMessage
        self.pollValue = apiMessage.response?.id ?? apiMessage.responses?.last?.id ?? pollValue
        self.privacyPolicyUrl = conversation.state.privacyPolicyUrl ?? self.privacyPolicyUrl
        
        // Handling human poll
        if let poll = state.poll {
            if poll != self.poll {
                self.poll = poll
            }
        }
        
        self.poll = state.poll ?? self.poll
        
        if poll && [ChatStatus.in_human_chat_queue, ChatStatus.assigned_to_human].contains(conversation.state.chatStatus) {
            startPolling()
        } else {
            stopPolling()
            pollValue = nil
        }
        
        // Handling change of van and language
        if let response = apiMessage.response {
            self.languageCode = response.language
            if self.vanId != response.vanId {
                if let vanId = response.vanId {
                    self.vanId = vanId
                } else {
                    self.vanId = nil
                }
                self.getConfig(completion: {
                    (config, error) in
                    self.configObservers.values.forEach { closure in
                        closure(self, config, error)
                    }
                })
            }
        }
    }
    
    func handleJsonEvent(apiMessage: APIMessage) {
        var messageResponses = apiMessage.responses ?? []

        if let response = apiMessage.response {
            messageResponses.append(response)
        }

        messageResponses.forEach { r in
            r.elements.forEach { element in
                if element.type == .json, let jsonData = element.payload.json {
                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(EmitEvent.self, from: jsonData)
                        DispatchQueue.main.async {
                            self.publishEvent(type: json.emitEvent.type, detail: json.emitEvent.detail)
                        }
                    } catch _ {}
                }
            }
        }
    }
}

/// Adding uploading of files
extension ChatBackend {
    func uploadFilesToAPI(at urls: [URL]) {
        if let endpoint = fileUploadServiceEndpointUrl, let endpointURL = URL(string: endpoint) {
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
            var fullData = Data()
            
            for url in urls {
                let fileName = url.lastPathComponent
                if let data = try? Data(contentsOf: url) {
                    let fileData = dataToFormData(data: data, boundary: boundary, fileName: fileName)
                    fullData.append(fileData as Data)
                }
            }
            
            let endBoundary = "--" + boundary + "--\r\n"
            fullData.append(endBoundary.data(using: .utf8)!)
            
            request.addValue(String(fullData.count), forHTTPHeaderField: "Content-Length")
            request.httpBody = fullData as Data
            
            urlSession.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    self.publishResponse(item: nil, error: error)
                    return
                }
                
                if let data = data, let wrapper = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any], let files = wrapper["files"] as? [[String: Any]] {
                    let f: [File] = files.compactMap { (dict) -> File? in
                        if let filename = dict["filename"] as? String, let mimeType = dict["mimeType"] as? String, let url = dict["url"] as? String {
                            return File(filename: filename, mimetype: mimeType, url: url)
                        }
                        
                        return nil
                    }
                    
                    self.sendFiles(files: f)
                }
            }.resume()
        } else {
            self.publishResponse(item: nil, error: SDKError.noUploadDefined("No file upload service defined"))
        }
    }
    
    func dataToFormData(data: Data, boundary: String, fileName: String) -> Data {
        var fullData = Data()
        
        let boundaryLine = "--" + boundary + "\r\n"
        fullData.append(boundaryLine.data(using: .utf8)!)
        
        let disposition = "Content-Disposition: form-data; name=\"files\"; filename=\"" + fileName + "\"\r\n"
        fullData.append(disposition.data(using: .utf8)!)
        
        let mimeType = MimeType(path: fileName).value
        let contentType = "Content-Type: \(mimeType)\r\n\r\n"
        fullData.append(contentType.data(using: .utf8)!)
        
        fullData.append(data)
        
        let newLine = "\r\n"
        fullData.append(newLine.data(using: .utf8)!)
        
        return fullData
    }
    
}

/// Add helper functions for sending a command
extension ChatBackend {
    public func send<T: CommandProtocol>(_ message: T, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = message
        switch message {
        case is CommandPost:
            var m = (message as! CommandPost)
            if m.clean == nil && self.clean {
                m.clean = true
            }
            if let filterValues = filter?.values {
                m.filterValues = filterValues
            }
            message = m as! T
        case is CommandResume:
            var m = (message as! CommandResume)
            if m.clean && self.clean {
                m.clean = true
            }
            message = m as! T
        case is CommandStart:
            var m = (message as! CommandStart)
            if let filterValues = filter?.values {
                m.filterValues = filterValues
            }
            message = m as! T
        default:
            break
        }
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(message)
            
            post(parameters: Data(jsonData)) { [weak self] (result, error) in
                guard let self = self else { return }
                
                if let postedId = result?.postedId, postedId > 0 {
                    self.pollValue = String(postedId)
                }
                
                if let item = result {
                    self.messages.append(item)
                }
                
                guard error == nil else {
                    self.publishResponse(item: nil, error: error)
                    completion?(result, error)
                    return
                }
                
                self.publishResponse(item: result, error: nil)
                completion?(result, error)
            }
        } catch let error {
            self.publishResponse(item: nil, error: error)
        }
    }
    
    private func publishResponse(item: APIMessage?, error: Error?) {
        messageObservers.values.forEach { closure in
            closure(self, item, error)
        }
    }
    
    func setupPostMessage(type: Type) -> CommandPost {
        return CommandPost(conversationId: self.conversationId,
                           userToken: self.userToken,
                           type: type,
                           skill: skill,
                           customPayload: customPayload)
    }
    
}

/// Add raw command functions
extension ChatBackend {
    
    /// START command
    ///
    /// This starts a conversation and is mandatory before any other commands, unless you set the conversation_id manually
    ///
    /// - Parameter message: An optional CommandStart if you want to set all the parameters of the start command
    public func start(message: CommandStart? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var m = message ?? CommandStart()
        m.userToken = m.userToken ?? userToken
        m.skill = m.skill ?? skill
        m.customPayload = m.customPayload ?? customPayload
        
        send(m, completion: completion)
    }
    
    /// STOP command
    ///
    /// This clears the conversation. You should call this to tell the API that the client is finished with the conversation
    ///
    /// - Parameter message: An optional CommandStop if you want to set all the parameters of the stop command
    public func stop(message: CommandStop? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        if self.allowDeleteConversation {
            send(message ?? CommandStop(conversationId: self.conversationId, userToken: self.userToken), completion: completion)
        } else {
            completion?(nil, nil)
        }
    }
    
    /// RESUME command
    /// - Parameter message: An optional CommandResume if you want to set all the parameters of the resume command
    public func resume(message: CommandResume? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var m = message ?? CommandResume()
        m.userToken = m.userToken ?? userToken
        m.skill = m.skill ?? skill
        
        send(m, completion: completion)
    }
    
    /// DELETE command
    /// - Parameter message: An optional CommandDelete if you want to set all the parameters of the delete command
    public func delete(message: CommandDelete? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message ?? CommandDelete(conversationId: self.conversationId, userToken: self.userToken), completion: { (message, error) in
            completion?(message, error)
            
            self.messages = []
            self.conversationId = nil
            self.userToken = nil
        })
    }
    
    /// POLL command
    ///
    /// This is mostly an internal command. The SDK will handle the poll for you.
    ///
    /// - Parameter message: An optional CommandPoll if you want to set all the parameters of the poll command
    public func poll(message: CommandPoll? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message ?? CommandPoll(conversationId: conversationId, userToken: self.userToken, value: pollValue ?? ""), completion: completion)
    }
    
    /// POLLSTOP command
    ///
    /// Call this if you want to stop a human poll sequence
    ///
    /// - Parameter message: An optional CommandPollStop if you want to set all the parameters of the pollstop command
    public func pollStop(message: CommandPollStop? = nil, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message ?? CommandPollStop(conversationId: self.conversationId, userToken: self.userToken), completion: completion)
    }
    
    public func smartReply(message: CommandSmartReply, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message, completion: completion)
    }
    
    public func humanChatPost(message: CommandHumanChatPost, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message, completion: completion)
    }
    
    /// This command is mostly internal. Try to use clientTyping(text) instead.
    public func typing(completion: ((APIMessage?, Error?) -> Void)? = nil) {
        if chatStatus==ChatStatus.virtual_agent {
            return
        }
        
        if let lastTyped = self.lastTyped {
            let now = Date()
            if now.timeIntervalSince(lastTyped) < 5 {
                return
            }
        }
        lastTyped = Date()
        send(CommandTyping(conversationId: self.conversationId, userToken: self.userToken), completion: completion)
    }
    
    /// FEEDBACK command
    ///
    /// This is mostly an internal command. Try to use conversationFeedback(rating, text) instead
    ///
    /// - Parameter message: An optional CommandFeedback if you want to set all the parameters of the feedback command
    public func conversationFeedback(message: CommandFeedback, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message, completion: completion)
    }
    
    /// DOWNLOAD command
    ///
    /// Use this to download the conversation as text. You will get the result in the APIMessage.download message
    ///
    /// - Parameter userToken: An optional userToken. If this is set the command will use this instead of the conversation_id
    public func download(userToken: String? = nil) {
        download() { (result, error) in
            self.publishResponse(item: result, error: error)
        }
    }
    
    /// LOGINEVENT command
    ///
    public func loginEvent(message: CommandLoginEvent, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        send(message, completion: completion)
    }
}

/// Adding CommandPost action types as functions
extension ChatBackend {
    
    /// If a response contains a list of buttons (links), you can trigger the action connected to the button with the
    /// link_id value in the response
    ///
    /// { "command": "POST", "type": "action_link", "conversation_id": String, "id": String}
    /// - parameter id: link_id from the buttons in the payload element list
    public func actionButton(id: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = setupPostMessage(type: Type.action_link)
        message.id = id
        send(message, completion: completion)
    }
    
    /// Use the message (type: text) when sending chat messages to the server
    ///
    /// { "command": "POST", "type": "type", "conversation_id": String, "value": String}
    /// - parameter value: A string to send
    public func message(value: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        if value.count > self.maxInputChars {
            publishResponse(item: nil, error: SDKError.tooLong("Too many characters in message"))
            return
        }
        var message = setupPostMessage(type: Type.text)
        message.setValue(value)
        
        // Store and publish the message sent so it can be rendered in the chatbot UI
        let uuid = UUID().uuidString
        let apiMessage = APIMessage(
            response: Response(
                id: uuid,
                source: .client,
                language: languageCode,
                elements: [Element(payload: Payload(text: value), type: .text)],
                dateCreated: Date()
            )
        )
        
        messages.append(apiMessage)
        publishResponse(item: apiMessage, error: nil)
        send(message, completion: completion)
    }
    
    /// User feedback allows your users to give thumbs up/down responses in you chat panel. Use the feedback function when sending *message* feedback
    ///
    /// { "command": "POST", "type": "feedback", "conversation_id": String, "id": String, "value": FeedbackValue}
    /// - parameter id: The id on the payload element you are giving feedback on
    /// - parameter value: Value of the feedback
    public func feedback(id: String, value: FeedbackValue, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = setupPostMessage(type: Type.feedback)
        message.id = id
        message.setValue(value)
        send(message, completion: completion)
    }
    
    /// External links do not trigger a response from the server, but they should be sent for logging purposes. If a response
    /// contains a list of buttons (links), you can log with this function
    ///
    /// {"command": "POST", "type": "external_link", "conversation_id": String, "id": String}
    /// - parameter id: id on external link in payload
    public func urlButton(id: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = setupPostMessage(type: Type.external_link)
        message.id = id
        send(message, completion: completion)
    }
    
    /// When the conversation state is awaiting_files, you can post this message to complete the entity extraction action
    /// TODO: Implement value
    ///
    /// {"command": "POST", "type": "files", "conversation_id": String, "value": [{ "filename": String, "mimetype": String, "url": String}]}
    /// - parameter files: Array of files
    public func sendFiles(files: [File], completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = setupPostMessage(type: Type.files)
        message.setValue(files)
        send(message, completion: completion)
    }
    
    /// Use this request type to trigger action flow elements directly
    ///
    /// {"command": "POST", "type": "trigger_action", "conversation_id": String, "id": String}
    /// - parameter id: action id
    public func triggerAction(id: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var message = setupPostMessage(type: Type.trigger_action)
        message.id = id
        send(message, completion: completion)
    }
    
    public func smartReply(value: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        let message = CommandSmartReply(conversationId: self.conversationId, userToken: self.userToken, value: value)
        send(message, completion: completion)
    }
    
    public func humanChatPost(value: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        let message = CommandHumanChatPost(conversationId: self.conversationId, userToken: self.userToken, value: value)
        send(message, completion: completion)
    }
    
    /// Inform the API that the client is typing
    /// - parameter value: The text the client has written so far in the textbox
    /// - Returns: ClientTyping including length and maxLength
    public func clientTyping(value: String) -> ClientTyping {
        if self.isBlocked {
            return ClientTyping(length: 0, maxLength: 0)
        }
        
        typing()
        return ClientTyping(length: value.count, maxLength: self.maxInputChars)
    }
    
    /// Feedback of the conversation
    ///
    ///  When a conversation ends, you might want to give the user the opportunity to give feedback on the conversation
    ///
    /// - parameter rating: 0 or 1. If above 1 it will be 1
    /// - parameter text: Optional text feedback
    public func conversationFeedback(rating: Int, text: String?, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        var feedback = CommandFeedbackValue(rating: rating>0 ? 1 : 0)
        if let text = text {
            feedback.text = text
        }
        let message = CommandFeedback(conversationId: self.conversationId, userToken: self.userToken, value: feedback)
        send(message, completion: completion)
    }
    
    public func loginEvent(userToken: String, completion: ((APIMessage?, Error?) -> Void)? = nil) {
        let message = CommandLoginEvent(conversationId: self.conversationId, userToken: userToken)
        send(message, completion: completion)
    }
}

extension ChatBackend {
    // Local message only. Used to display action link clicks as user message bubbles
    func userActionMessage(_ message: String) {
        let apiMessage = APIMessage(
            response: Response(
                id: UUID().uuidString,
                source: .client,
                language: languageCode,
                elements: [Element(payload: Payload(text: message), type: .text)],
                dateCreated: Date()
            )
        )

        messages.append(apiMessage)
        publishResponse(item: apiMessage, error: nil)
    }
}

extension ChatBackend {

    public func startPolling() {
        DispatchQueue.main.async {
            self.pollTimer?.invalidate()
            
            self.pollTimer = Timer.scheduledTimer(withTimeInterval: self.pollInterval, repeats: true) { [weak self] (timer) in
                self?.poll()
            }
        }
    }
    
    public func stopPolling() {
        DispatchQueue.main.async {
            self.pollTimer?.invalidate()
            self.pollTimer = nil
        }
    }
    
}

private extension ChatBackend {
    enum State {
        case idle
        case newMessage(APIMessage)
    }
}

extension ChatBackend {
    @discardableResult
    public func addMessageObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (APIMessage?, Error?) -> Void
    ) -> ObservationToken {
        let id = UUID()
        
        messageObservers[id] = { [weak self, weak observer] backend, item, error in
            
            guard observer != nil else {
                self?.messageObservers.removeValue(forKey: id)
                return
            }
            
            guard error == nil else {
                print("Found error in observer data")
                closure(nil, error)
                return
            }
            closure(item, nil)
        }
        
        return ObservationToken { [weak self] in
            self?.messageObservers.removeValue(forKey: id)
        }
    }
    
    @discardableResult
    @available(*, deprecated, renamed: "addMessageObserver")
    public func newMessageObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (APIMessage?, Error?) -> Void
    ) -> ObservationToken {
        return addMessageObserver(observer, closure: closure)
    }
}

extension ChatBackend {
    @discardableResult
    public func addConfigObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (ChatConfig?, Error?) -> Void
    ) -> ObservationToken {
        let id = UUID()
        
        configObservers[id] = { [weak self, weak observer] backend, item, error in
            
            guard observer != nil else {
                self?.configObservers.removeValue(forKey: id)
                return
            }
            
            guard error == nil else {
                print("Found error in observer data")
                closure(nil, error)
                return
            }
            closure(item, nil)
        }
        
        return ObservationToken { [weak self] in
            self?.configObservers.removeValue(forKey: id)
        }
    }
    
    @discardableResult
    @available(*, deprecated, renamed: "addConfigObserver")
    public func newConfigObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (ChatConfig?, Error?) -> Void
    ) -> ObservationToken {
        return addConfigObserver(observer, closure: closure)
    }
}

extension ChatBackend {
    @discardableResult
    public func addEventObserver<T: AnyObject>(
        _ observer: T,
        closure: @escaping (String, Any?) -> Void
    ) -> ObservationToken {
        let id = UUID()
        
        eventObservers[id] = { [weak self, weak observer] backend, eventType, detail in
            
            guard observer != nil else {
                self?.eventObservers.removeValue(forKey: id)
                return
            }
            
            closure(eventType, detail)
        }
        
        return ObservationToken { [weak self] in
            self?.eventObservers.removeValue(forKey: id)
        }
    }
    
    private func publishEvent(type: String, detail: Any?) {
        eventObservers.values.forEach { closure in
            closure(self, type, detail)
        }
    }
}

