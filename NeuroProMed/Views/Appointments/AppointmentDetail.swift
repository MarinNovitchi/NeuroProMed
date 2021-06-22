//
//  AppointmentDetail.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct AppointmentDetail: View {
    
    let prefix: Text
    let detail: Text
    
    var body: some View {
        HStack {
            prefix
                .foregroundColor(.secondary)
            Spacer()
            detail
                .foregroundColor(.primary)
        }
    }
}

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(prefix: Text("prefix"), detail: Text("detail"))
    }
}
