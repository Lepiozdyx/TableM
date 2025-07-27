//
//  LoadingView.swift
//  TableM
//
//  Created by Alex on 27.07.2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Image(.bgLoading)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ProgressView()
                    .colorInvert()
                    .scaleEffect(1.5)
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    LoadingView()
}
