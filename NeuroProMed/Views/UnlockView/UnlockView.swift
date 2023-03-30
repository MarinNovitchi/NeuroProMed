//
//  UnlockView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 13.06.2021.
//

import SwiftUI

struct UnlockView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Image("neuropromed_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .blur(radius: 13.0)
            VStack {
                Spacer()
                if viewModel.isRetryButtonDisplayed {
                    Button(label(.retryAuthentication)) { viewModel.authenticate() }
                }
            }
        }
        .padding(50)
        .onAppear { viewModel.authenticate() }
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(viewModel: .init())
    }
}
