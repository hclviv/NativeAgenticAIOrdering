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

    // Checkout flow
    var showOrderDetailsSheet: Bool = false
    var showApplePaySheet: Bool = false
    var applePayLocationName: String? = nil
    var applePayOrderTotal: Double? = nil
    private var pendingOrderFormData: OrderFormData? = nil

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

        // Intercept checkout intent — show order details form before calling the API
        if isCheckoutIntent(messageText) {
            let userMessage = Message(text: messageText, isUser: true)
            messages.append(userMessage)
            currentInput = ""
            applePayLocationName = extractLocationName()
            applePayOrderTotal = extractOrderTotal()
            showOrderDetailsSheet = true
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

    /// Called when user taps "Place Order" in the order details form
    func proceedToApplePay(formData: OrderFormData) {
        showOrderDetailsSheet = false
        pendingOrderFormData = formData
        showApplePaySheet = true
    }

    /// Called when user cancels the order details form
    func cancelOrderDetails() {
        showOrderDetailsSheet = false
    }

    /// Called when user completes Apple Pay — calls checkout + placeOrder directly
    func completeApplePay() {
        showApplePaySheet = false
        guard let formData = pendingOrderFormData,
              let conversationId = conversationId else { return }
        pendingOrderFormData = nil

        Task {
            isTyping = true
            do {
                let response = try await apiClient.completeCheckout(
                    conversationId: conversationId,
                    formData: formData
                )
                let assistantMessage = Message(
                    text: response.confirmationText,
                    isUser: false
                )
                messages.append(assistantMessage)
            } catch {
                handleError(error)
            }
            isTyping = false
        }
    }

    /// Called when user cancels Apple Pay
    func cancelApplePay() {
        showApplePaySheet = false
        pendingOrderFormData = nil
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
        showOrderDetailsSheet = false
        showApplePaySheet = false
        applePayOrderTotal = nil
        pendingOrderFormData = nil
        await startConversation()
    }

    // MARK: - Private Methods

    private func addWelcomeMessage() {
        let welcomeText = "Welcome to Jimmy John's Catering! 🥪\n\nI'm here to help you order catering for your event. To get started, please share your ZIP code so I can find nearby Jimmy John's locations."
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

    private func isCheckoutIntent(_ message: String) -> Bool {
        let lower = message.lowercased()
        let keywords = ["checkout", "check out", "proceed to checkout", "place order", "ready to order"]
        return keywords.contains(where: { lower.contains($0) })
    }

    private func extractLocationName() -> String? {
        // Find location name from the most recent assistant message that mentioned a store
        for message in messages.reversed() where !message.isUser {
            if let uiModel = message.uiModel, case .menu(let menuModel) = uiModel {
                return menuModel.locationName
            }
        }
        return nil
    }

    private func extractOrderTotal() -> Double? {
        // Scan recent assistant messages for "Total: $XX.XX" pattern
        let pattern = #"[Tt]otal[:\s*\*]+\$([0-9]+\.[0-9]{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        for message in messages.reversed() where !message.isUser {
            let text = message.text
            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, range: range),
               let valueRange = Range(match.range(at: 1), in: text) {
                return Double(text[valueRange])
            }
        }
        return nil
    }
}
