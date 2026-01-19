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
                
            Rectangle()
                    .colorMultiply(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.all, 50)
            }
            .padding()
        }
    }
}

#Preview {
    GameView()
}
