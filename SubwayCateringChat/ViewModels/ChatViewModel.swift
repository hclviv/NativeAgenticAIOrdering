//
//  ChatViewModel.swift
//  SubwayCateringChat
//
//  ViewModel for managing chat state and API interactions
//

import Foundation
import Observation

@MainActor
@Observable
class ChatViewModel {
    // MARK: - Published State

    var messages: [Message] = []
    var currentInput: String = ""
    var isLoading: Bool = false
    var isTyping: Bool = false
    var errorMessage: String?
    var conversationId: String?
    var menuShownInMessageId: UUID?

    // MARK: - Private Properties

    private let apiClient: APIClient
    private var conversationStateVersion: Int = 0

    // MARK: - Initialization

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func startConversation() async {
        guard conversationId == nil else { return }

        isLoading = true
        errorMessage = nil

        do {
            conversationId = try await apiClient.createConversation()
            // Add welcome message
            addWelcomeMessage()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    func sendMessage(_ text: String? = nil) async {
        let messageText = text ?? currentInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !messageText.isEmpty else { return }
        guard let conversationId = conversationId else {
            errorMessage = "No active conversation. Please restart the app."
            return
        }

        // Add user message to UI
        let userMessage = Message(text: messageText, isUser: true)
        messages.append(userMessage)

        // Clear input
        currentInput = ""

        // Show typing indicator
        isTyping = true
        errorMessage = nil

        do {
            // Send message to BFF
            let response = try await apiClient.sendMessage(
                conversationId: conversationId,
                message: messageText
            )

            // Update state version
            conversationStateVersion = response.conversationStateVersion

            // Add delay for better UX (simulates thinking)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Add assistant response
            let assistantMessage = Message(
                text: response.assistantText,
                isUser: false,
                suggestedActions: response.suggestedActions,
                uiModel: response.uiModel
            )
            messages.append(assistantMessage)

        } catch {
            handleError(error)
        }

        isTyping = false
    }

    func selectSuggestedAction(_ action: String) async {
        // Clean up the action text to match what BFF expects
        var cleanedAction = action

        // Remove "Select " prefix if present (e.g., "Select Subway - Shelton, CT" -> "Subway - Shelton, CT")
        if cleanedAction.hasPrefix("Select ") {
            cleanedAction = String(cleanedAction.dropFirst(7)) // Remove "Select "
        }

        await sendMessage(cleanedAction)
    }

    func clearError() {
        errorMessage = nil
    }

    func resetConversation() async {
        messages.removeAll()
        conversationId = nil
        conversationStateVersion = 0
        errorMessage = nil
        currentInput = ""
        menuShownInMessageId = nil
        await startConversation()
    }

    // MARK: - Private Methods

    private func addWelcomeMessage() {
        let welcomeText = "Welcome to Subway Catering! 🥪\n\nI'm here to help you order catering for your event. To get started, please share your ZIP code so I can find nearby Subway locations."
        let welcomeMessage = Message(
            text: welcomeText,
            isUser: false,
            suggestedActions: nil
        )
        messages.append(welcomeMessage)
    }

    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
