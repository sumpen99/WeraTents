//
//  StyledWindowGroup.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

public struct StyledWindowGroup<Content: View>: Scene {
    
    @ViewBuilder let content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some Scene {
        WindowGroup {
            content()
                .backgroundPreferenceValue(PreferredWindowColorKey.self) { color in
                    WindowProxyHostView(backgroundColor: color)
                }
        }
    }
}

// MARK: - Convenience View Modifer
extension View {
    public func preferredWindowColor(_ color: Color) -> some View {
        preference(key: PreferredWindowColorKey.self, value: color)
    }
}

// MARK: - Preference Key

fileprivate struct PreferredWindowColorKey: PreferenceKey {
    static let defaultValue = Color.white
    static func reduce(value: inout Color, nextValue: () -> Color) { }
}

// MARK: - Window Proxy View Pair

fileprivate struct WindowProxyHostView: UIViewRepresentable {
    
    let backgroundColor: Color
    
    func makeUIView(context: Context) -> WindowProxyView {
        let view = WindowProxyView(frame: .zero)
        view.isHidden = true
        return view
    }
    
    func updateUIView(_ view: WindowProxyView, context: Context) {
        view.rootViewBackgroundColor = backgroundColor
    }
}

fileprivate final class WindowProxyView: UIView {
    
    var rootViewBackgroundColor = Color.white {
        didSet { updateRootViewColor(on: window) }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        updateRootViewColor(on: newWindow)
    }
    
    private func updateRootViewColor(on window: UIWindow?) {
        guard let rootViewController = window?.rootViewController else { return }
        rootViewController.view.backgroundColor = UIColor(rootViewBackgroundColor)
    }
}

