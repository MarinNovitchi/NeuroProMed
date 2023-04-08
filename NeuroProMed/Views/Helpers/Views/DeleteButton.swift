//
//  DeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct DeleteButton: View {
    
    @Binding var activeAlert: ActiveAlert?
    let title: String
    
    private func triggerWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        activeAlert = .warning
    }
    
    var body: some View {
        Section {
            ListButton(title: title, action: triggerWarning)
                .foregroundColor(Color.red)
        }
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(activeAlert: .constant(.warning), title: "Delete Object")
    }
}
