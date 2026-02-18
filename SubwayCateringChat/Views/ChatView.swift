//
//  ChatView.swift
//  SubwayCateringChat
//
//  Main chat interface
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                VStack(spacing: 12) {
                                    // Determine if this message's menu/locations should be shown
                                    let isMenuModel = isMenuUIModel(message.uiModel)
                                    let shouldShowUIModel: Bool = {
                                        guard message.uiModel != nil else { return false }
                                        // Always show locations
                                        if !isMenuModel { return true }
                                        // Show menu if this is the message that first showed it
                                        if viewModel.menuShownInMessageId == message.id { return true }
                                        // Show menu if no message has shown it yet
                                        return viewModel.menuShownInMessageId == nil
                                    }()

                                    // Hide assistant text when showing menu, show it for everything else
                                    if !(shouldShowUIModel && isMenuModel) {
                                        MessageBubbleView(message: message)
                                            .id(message.id)
                                    }

                                    // Show UI Models
                                    if shouldShowUIModel, let uiModel = message.uiModel {
                                        UIModelView(
                                            uiModel: uiModel,
                                            onLocationSelect: { location in
                                                handleLocationSelection(location)
                                            },
                                            onMenuItemSelect: { item in
                                                handleMenuItemSelection(item)
                                            }
                                        )
                                        .onAppear {
                                            // Remember which message showed the menu
                                            if isMenuModel && viewModel.menuShownInMessageId == nil {
                                                viewModel.menuShownInMessageId = message.id
                                            }
                                        }
                                    }

                                    // Show suggested actions only before ordering flow (before menu is shown)
                                    if let actions = message.suggestedActions, !actions.isEmpty,
                                       message.id == viewModel.messages.last?.id,
                                       viewModel.menuShownInMessageId == nil {
                                        SuggestedActionsView(actions: actions) { action in
                                            Task {
                                                await viewModel.selectSuggestedAction(action)
                                            }
                                        }
                                    }
                                }
                            }

                            // Typing indicator
                            if viewModel.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { oldCount, newCount in
                        // Only scroll when a new message is added
                        if newCount > oldCount {
                            scrollToBottom(proxy: proxy, animated: true)
                        }
                    }
                }

                Divider()

                // Error Banner
                if let error = viewModel.errorMessage {
                    ErrorBannerView(message: error) {
                        viewModel.clearError()
                    }
                }

                // Input Area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $viewModel.currentInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                        .disabled(viewModel.isLoading || viewModel.isTyping)

                    Button(action: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(canSendMessage ? .green : .gray)
                    }
                    .disabled(!canSendMessage)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Subway Catering")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            Task {
                                await viewModel.resetConversation()
                            }
                        }) {
                            Label("New Conversation", systemImage: "plus.message")
                        }

                        Button(role: .destructive, action: {
                            // Add any cleanup logic
                        }) {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.green)
                    }
                }
            }
            .task {
                await viewModel.startConversation()
            }
        }
    }

    // MARK: - Computed Properties

    private var canSendMessage: Bool {
        !viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isLoading
            && !viewModel.isTyping
    }

    // MARK: - Helper Methods

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        // Small delay to allow content to layout
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

            if animated {
                withAnimation(.easeOut(duration: 0.25)) {
                    performScroll(proxy: proxy)
                }
            } else {
                performScroll(proxy: proxy)
            }
        }
    }

    private func performScroll(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .top)
        }
    }

    private func handleLocationSelection(_ location: Location) {
        Task {
            // Send just the location name as that's what the BFF expects
            await viewModel.sendMessage(location.name)
        }
    }

    private func handleMenuItemSelection(_ item: MenuItem) {
        Task {
            await viewModel.sendMessage("Add \(item.name) to my order")
        }
    }

    private func isMenuUIModel(_ uiModel: UIModel?) -> Bool {
        guard let uiModel = uiModel else { return false }
        if case .menu = uiModel { return true }
        return false
    }
}

// MARK: - UI Model View

struct UIModelView: View {
    let uiModel: UIModel
    let onLocationSelect: (Location) -> Void
    let onMenuItemSelect: (MenuItem) -> Void

    var body: some View {
        switch uiModel {
        case .locations(let locationsModel):
            LocationsListView(
                locationsModel: locationsModel,
                onLocationSelect: onLocationSelect
            )

        case .menu(let menuModel):
            MenuListView(
                menuModel: menuModel,
                onItemSelect: onMenuItemSelect
            )
        }
    }
}

// MARK: - Error Banner

struct ErrorBannerView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(2)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    ChatView()
}
