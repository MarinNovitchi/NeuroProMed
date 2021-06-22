//
//  BiometricsSettingsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 22.05.2021.
//

import LocalAuthentication
import SwiftUI

struct BiometricsSettingsView: View {

    @Binding var useBiometrics: Bool
    let biometrics = BiometricsHelper()
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func toggleSet(_ newValue: Bool) {
        if biometrics.isDeviceUnsupportedOrPermissionDenied() {
            isShowingAlert = true
            alertMessage = label(.biometricsPermissionRequest)
        } else {
            if !useBiometrics {
                useBiometrics = newValue
            } else {
                biometrics.authenticate { isAuthenticated in
                    if isAuthenticated {
                        useBiometrics = false
                    }
                }
            }
        }
    }
    
    var body: some View {
        CustomSection(header: Text(label(.configuration))) {
            Toggle(isOn: Binding<Bool>(
                    get: { useBiometrics },
                    set: toggleSet
        )) {
                Text(label(.biometricsUseTitle))
            }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            
            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                Text(label(.appSettings))
            }

        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text(label(.biometricsPermissionDenied)),
                message: Text(alertMessage),
                primaryButton: .cancel(),
                secondaryButton: .default(Text(label(.appSettings)), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
            )
        }
    }
}

struct BiometricsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricsSettingsView(useBiometrics: .constant(false))
    }
}
