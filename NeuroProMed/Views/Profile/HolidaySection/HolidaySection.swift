//
//  HolidaySection.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.05.2021.
//

import SwiftUI

struct HolidaySection: View {
    
    @StateObject var viewModel: ViewModel
    @Binding var doctorData: Doctor.DoctorProperties
    
    func removeHolidays(year: Int, month: Int, at offset: IndexSet) {
        if let dateToRemove = viewModel.findDate(from: doctorData.unavailability, at: offset, year: year, month: month) {
            doctorData.unavailability.removeAll(where: { $0.compare(dateToRemove) == .orderedSame })
        }
    }
    
    let isSectionEditable: Bool
    
    var body: some View {
        Group {
            ForEach(viewModel.getDoctorUnavailability(from: doctorData).keys.sorted(), id: \.self) { yearIndex in
                ForEach(viewModel.getDoctorUnavailability(from: doctorData)[yearIndex]!.sorted(), id: \.self) { monthIndex in
                    
                    CustomSection(header: Text(viewModel.sectionHeader(y: yearIndex, m: monthIndex))) {
                        ForEach(viewModel.unavailableDatesfilteredBy(year: yearIndex, month: monthIndex, from: doctorData.unavailability), id: \.self) { unavailableDate in
                            HStack {
                                Text(unavailableDate, style: .date)
                                    .foregroundColor(.primary)
                                Text(viewModel.getDayOfWeek(from: unavailableDate))
                                    .foregroundColor(.secondary)
                            }
                            .deleteDisabled(!isSectionEditable)
                        }
                        .onDelete(perform: { indexSet in
                            removeHolidays(year: yearIndex, month: monthIndex, at: indexSet)
                        })
                    }
                }
            }
        }
    }
}

struct HolidaySection_Previews: PreviewProvider {
    static var previews: some View {
        HolidaySection(viewModel: .init(), doctorData: .constant(Doctor.example), isSectionEditable: true)
    }
}
