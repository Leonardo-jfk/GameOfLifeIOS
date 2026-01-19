//
//  ContentView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            Image("BackLight")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
