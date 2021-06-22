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
    
    @Binding var isAuthenticated: Bool
    @Binding var isUserDoctor: Bool
    @Binding var doctorID: String
    @Binding var userID: UUID
    
    @State private var requestState = UUID()
    @State private var requestNonce = UUID()
    
    @State private var alertMessage = ""
    @State private var isAlertPresented = false
    
    func setUp(_ request: ASAuthorizationAppleIDRequest) {
        if isUserDoctor {
            guard let unwrappedDoctorID = UUID(uuidString: doctorID) else { return }
            userID = unwrappedDoctorID
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
            userID: userID,
            firstName: credentials.fullName?.givenName,
            lastName: credentials.fullName?.familyName,
            isDoctor: isUserDoctor
        )
        let completion: (Result<Authentication, NetworkError>) -> Void = { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success(let result):
                generator.notificationOccurred(.success)
                completeAuthentication(with: result)
            case .failure(let error):
                generator.notificationOccurred(.error)
                alertMessage = error.getMessage()
                isAlertPresented = true
            }
        }
            ApiHandler.request(.POST, at: "/authenticate", body: auth, completion: completion)
        }
    }
    
    func completeAuthentication(with result: Authentication) {
        saveToKeychain(result)
        userID = result.userID
        isUserDoctor = result.isDoctor
        isAuthenticated = true
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
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                setUp(request)
            },
            onCompletion: { result in
                validateAuthentication(result)
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(width: 280, height: 60)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .disabled(isUserDoctor && UUID(uuidString: doctorID) == nil)
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct SignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInButton(
            isAuthenticated: .constant(false),
            isUserDoctor: .constant(true),
            doctorID: .constant(""),
            userID: .constant(UUID()))
    }
}
