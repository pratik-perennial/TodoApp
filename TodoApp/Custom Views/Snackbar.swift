//
//  Snackbar.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//


import SwiftUI

struct Snackbar: View {
    let message: String
    
    @State private var isVisible: Bool = true
    
    var body: some View {
        if isVisible {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.85))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            //isVisible = false
                        }
                    }
                }
        }
    }
}
