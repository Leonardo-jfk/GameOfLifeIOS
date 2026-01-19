//
//  GameView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import Foundation
import SwiftUI

struct GameView: View {
    var body: some View {
        ZStack{
            Image("BackLight")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .colorMultiply(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.all, 50)
//                    .cornerRadius(30)
            }
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .colorMultiply(.white)
//                    .opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.all, 70)
//                    .cornerRadius(30)
            }
            .padding()
        }
    }
}

#Preview {
    GameView()
}
