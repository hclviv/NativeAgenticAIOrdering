//
//  NetworkImage.swift
//  SubwayCateringChat
//
//  Custom image loader that works through corporate SSL inspection proxies.
//  Standard AsyncImage fails when a proxy (e.g. Capgemini Zscaler) intercepts
//  HTTPS and re-signs with a corporate CA that iOS doesn't trust by default.
//

import SwiftUI

// MARK: - NetworkImage View

struct NetworkImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task { await loadImage() }
            }
        }
    }

    private func loadImage() async {
        guard !isLoading, let url else { return }
        isLoading = true
        uiImage = await ImageLoader.shared.load(url)
        isLoading = false
    }
}

// MARK: - Image Loader (bypass corporate SSL inspection)

@MainActor
class ImageLoader: NSObject {
    static let shared = ImageLoader()

    private var cache: [URL: UIImage] = [:]
    private lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: SSLBypassDelegate(), delegateQueue: nil)
    }()

    func load(_ url: URL) async -> UIImage? {
        if let cached = cache[url] { return cached }

        do {
            let (data, _) = try await session.data(from: url)
            if let image = UIImage(data: data) {
                cache[url] = image
                return image
            }
        } catch {
            print("⚠️ NetworkImage failed to load \(url): \(error.localizedDescription)")
        }
        return nil
    }
}

// MARK: - SSL Bypass Delegate

private class SSLBypassDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Accept corporate proxy certificates (e.g. Capgemini SSL inspection)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
