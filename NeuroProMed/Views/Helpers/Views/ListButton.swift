//
//  ListButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.06.2021.
//

import SwiftUI

struct ListButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(title, action: action)
            Spacer()
        }
    }
}

struct ListButton_Previews: PreviewProvider {
    static var previews: some View {
        ListButton(title: "Button label", action: {})
    }
}
