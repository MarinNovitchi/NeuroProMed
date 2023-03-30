//
//  SignInButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.06.2021.
//

import AuthenticationServices
import SwiftUI

struct SignInButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var doctorID: String
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                viewModel.setUp(request, for: doctorID)
            },
            onCompletion: { result in
                viewModel.validateAuthentication(result)
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(width: 280, height: 60)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .disabled(viewModel.isUserDoctor && UUID(uuidString: doctorID) == nil)
        .alert(isPresented: $viewModel.isAlertPresented) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct SignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInButton(doctorID: .constant(""), viewModel: .init(), appState: .shared)
    }
}
