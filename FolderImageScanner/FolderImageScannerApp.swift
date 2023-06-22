//
//  FolderImageScannerApp.swift
//  FolderImageScanner
//
//  Created by Taha Tuna on 21.06.2023.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

@main
struct FolderImageScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 350, height: 200)
                .fixedSize()
                .background(VisualEffect().ignoresSafeArea())
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

