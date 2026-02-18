//
//  APIClient.swift
//  SubwayCateringChat
//
//  Network client for BFF API communication
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(String, Int)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message, let statusCode):
            return "Server error (\(statusCode)): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

@MainActor
class APIClient {
    static let shared = APIClient()

    private let baseURL = "http://172.18.32.76:3000/v1"//"http://localhost:3000/v1"
    private let session: URLSession
    private let enableDebugLogging = true // Set to false to disable logs

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Debug Logging

    private func logRequest(_ request: URLRequest) {
        guard enableDebugLogging else { return }
        print("\n🌐 API Request:")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    private func logResponse(_ data: Data, _ response: URLResponse) {
        guard enableDebugLogging else { return }
        print("\n📥 API Response:")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("Body: \(responseString)")
        }
        print("")
    }

    private func logError(_ error: Error) {
        guard enableDebugLogging else { return }
        print("\n❌ API Error: \(error.localizedDescription)\n")
    }

    // MARK: - API Methods

    func createConversation() async throws -> String {
        guard let url = URL(string: "\(baseURL)/conversations") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)
            logResponse(data, response)

            try validateResponse(response)

            let conversationResponse = try JSONDecoder().decode(CreateConversationResponse.self, from: data)
            return conversationResponse.conversationId
        } catch let error as APIError {
            logError(error)
            throw error
        } catch {
            logError(error)
            throw APIError.networkError(error)
        }
    }

    func sendMessage(conversationId: String, message: String) async throws -> ChatResponse {
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let chatRequest = ChatRequest(conversationId: conversationId, userMessage: message)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // For better logging
        request.httpBody = try encoder.encode(chatRequest)

        logRequest(request)

        do {
            let (data, response) = try await session.data(for: request)
            logResponse(data, response)

            try validateResponse(response, data: data)

            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse
        } catch let error as APIError {
            logError(error)
            throw error
        } catch {
            logError(error)
            throw APIError.networkError(error)
        }
    }

    func checkHealth() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw APIError.invalidURL
        }

        do {
            let (_, response) = try await session.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Helper Methods

    private func validateResponse(_ response: URLResponse, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response
            if let data = data,
               let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message, errorResponse.statusCode)
            }
            throw APIError.serverError("HTTP \(httpResponse.statusCode)", httpResponse.statusCode)
        }
    }
}
