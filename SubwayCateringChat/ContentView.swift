//
//  ContentView.swift
//  SubwayCateringChat
//
//  Created by Vivek Shrivastav on 2/18/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                ChatView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isLoading)
        .task {
            // Show splash for 1.5 seconds
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isLoading = false
        }
    }
}

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.jjRed
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)

                VStack(spacing: 8) {
                    Text("Jimmy John's Catering")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Powered by AI")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    ContentView()
}
