//
//  ScoreboardView.swift
//  TableM
//
//  Created by Alex on 26.07.2025.
//

import SwiftUI

struct ScoreboardView: View {
    var coins: Int
    
    var body: some View {
        Image(.scoreboard)
            .resizable()
            .frame(width: 130, height: 50)
            .overlay {
                Text("\(coins)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.indigo)
                    .offset(x: -10)
            }
    }
}

