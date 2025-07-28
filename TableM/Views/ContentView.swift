//
//  ContentView.swift
//  TableM
//
//  Created by Alex on 28.07.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var state = AppStateViewModel()
        
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
                
            case .supp:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                    
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                }
                
            case .final:
                MainMenuView()
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    ContentView()
}
