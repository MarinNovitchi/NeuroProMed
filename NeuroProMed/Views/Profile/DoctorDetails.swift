//
//  DoctorDetails.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct DoctorDetails: View {
    
    @ObservedObject var doctor: Doctor
    
    var body: some View {
        CustomSection(header: Text(label(.doctorDetails))) {
            if let unwrappedEmail = doctor.email {
                Text(unwrappedEmail)
            }
            Text(doctor.specialty)
            Text(doctor.isWorkingWeekends ? label(.isWorkingWeekends) : label(.isNotWorkingWeekends))
        }
    }
}

struct DoctorDetails_Previews: PreviewProvider {
    static var previews: some View {
        DoctorDetails(doctor: Doctor(using: Doctor.example))
    }
}
