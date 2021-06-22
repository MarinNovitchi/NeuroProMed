//
//  UnlockView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 13.06.2021.
//

import SwiftUI

struct UnlockView: View {
    
    @Binding var isUnlocked: Bool
    
    @State private var isRetryButtonDisplayed = false
    @State private var alertMessage = ""
    @State var activeAlert: ActiveAlert?
    
    func authenticate() {
        let biometrics = BiometricsHelper()
        if biometrics.isDeviceUnsupportedOrPermissionDenied() {
            activeAlert = .settingsIssue
            alertMessage = label(.biometricsPermissionRequest)
        } else {
            biometrics.authenticate { isEnabled in
                isUnlocked = isEnabled
                isRetryButtonDisplayed = !isEnabled
            }
        }
    }
    
    var body: some View {
        ZStack {
            Image("neuropromed_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .blur(radius: 13.0)
            VStack {
                Spacer()
                if isRetryButtonDisplayed {
                    Button(label(.retryAuthentication), action: authenticate)
                }
            }
        }
        .padding(50)
        .onAppear(perform: authenticate)
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(isUnlocked: .constant(false))
    }
}
