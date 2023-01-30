//
//  SignInButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.06.2021.
//

import AuthenticationServices
import SwiftUI

extension SignInButton {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var requestState = UUID()
        @Published var requestNonce = UUID()
        
        @Published var alertMessage = ""
        @Published var isAlertPresented = false
        
        func setUp(_ request: ASAuthorizationAppleIDRequest, for doctorID: String) {
            if isUserDoctor {
                guard let unwrappedDoctorID = UUID(uuidString: doctorID) else { return }
                appState.userID = unwrappedDoctorID
            }
            request.requestedScopes = [isUserDoctor ? .email : .fullName]
            request.state = requestState.uuidString
            request.nonce = requestNonce.uuidString
        }
        
        func validateAuthentication(_ result: Result<ASAuthorization, Error>) {
            switch result {
            case .failure(let error):
                alertMessage = error.localizedDescription
                isAlertPresented = true
            case .success(let authResults):
                guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential,
                      let identityToken = credentials.identityToken,
                      let identityTokenString = String(data: identityToken, encoding: .utf8)
                else { return }
                guard credentials.state == requestState.uuidString else {
                    alertMessage = label(.wrongAuthState)
                    isAlertPresented = true
                    return
                }
            let auth = Authentication(
                identityToken: identityTokenString,
                userIdentifier: credentials.user,
                nonce: requestNonce.uuidString,
                userID: AppState.shared.userID,
                firstName: credentials.fullName?.givenName,
                lastName: credentials.fullName?.familyName,
                isDoctor: AppState.shared.isUserDoctor
            )
            let completion: (Result<Authentication, AppError>) -> Void = { response in
                let generator = UINotificationFeedbackGenerator()
                switch response {
                case .success(let result):
                    generator.notificationOccurred(.success)
                    self.completeAuthentication(with: result)
                case .failure(let error):
                    generator.notificationOccurred(.error)
                    self.alertMessage = error.getMessage()
                    self.isAlertPresented = true
                }
            }
                //ApiHandler.request(.POST, at: "/authenticate", body: auth, completion: completion)
            }
        }
        
        func completeAuthentication(with result: Authentication) {
            saveToKeychain(result)
            AppState.shared.userID = result.userID
            AppState.shared.isUserDoctor = result.isDoctor
            AppState.shared.isAuthenticated = true
        }
        
        func saveToKeychain(_ authentication: Authentication) {
            let keychainHelper = KeychainHelper()
            do {
                try keychainHelper.saveCredentials(userID: authentication.userID, isDoctor: authentication.isDoctor)
            } catch  {
                alertMessage = label(.failToStoreKeychain)
                isAlertPresented = true
            }
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}

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
