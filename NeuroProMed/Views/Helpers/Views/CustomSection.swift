//
//  CustomSection.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2021.
//

import SwiftUI

struct CustomSection<Content: View>: View {
    
    var header: Text
    var footer: Text?
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if let unwrappedFooter = footer {
            Section(header: header.foregroundColor(Color("ComplimentaryColor")), footer: unwrappedFooter, content: content)
        } else {
            Section(header: header.foregroundColor(Color("ComplimentaryColor")), content: content)
        }
    }
}
