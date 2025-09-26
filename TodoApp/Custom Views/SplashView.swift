//
//  SplashView.swift
//  TodoApp
//
//  Created by Pratik on 26/09/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundColor(.accentColor)
        }
    }
}

#Preview {
    SplashView()
}


