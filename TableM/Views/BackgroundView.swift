//
//  BackgroundView.swift
//  TableM
//
//  Created by Alex on 26.07.2025.
//

import SwiftUI

struct BackgroundView: View {
    @ObservedObject var playerProgress: PlayerProgressViewModel
    
    var body: some View {
        Image(playerProgress.getSelectedBackgroundImageName())
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(playerProgress: PlayerProgressViewModel())
}
