//
//  HolidaySection.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.05.2021.
//

import SwiftUI

extension HolidaySection {
    
    class ViewModel: ObservableObject {
        
        func getDoctorUnavailability(from doctorData: Doctor.DoctorProperties) -> [Int: [Int]] {
            let unavailabilityGroupedByYear = Dictionary(grouping: doctorData.unavailability) {
                Calendar.current.dateComponents([.year], from: $0).year ?? 1900
            }
            return unavailabilityGroupedByYear.mapValues({
                Array(Set($0.map({
                    Calendar.current.dateComponents([.month], from: $0).month ?? 0
                })))
            })
        }
        
        func findDate(from dates: [Date], at offset: IndexSet, year: Int, month: Int) -> Date? {
            let section = filterAndSortDatesArray(dates: dates, year: year, month: month)
            return section[offset.first ?? -1 ]
        }
        
        private func filterAndSortDatesArray(dates: [Date], year: Int, month: Int) -> [Date] {
            return dates.filter{
                let components = Calendar.current.dateComponents([.year, .month], from: $0)
                return components.month == month && components.year == year
            }.sorted(by: { $0.compare($1) == .orderedAscending })
        }
        
        func unavailableDatesfilteredBy(year: Int, month: Int, from dates: [Date]) -> [Date] {
            return filterAndSortDatesArray(dates: dates, year: year, month: month)
        }
        
        func sectionHeader(y yearIndex: Int, m monthIndex: Int) -> Text {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.monthSymbols[monthIndex - 1]
            
            return Text("\(String(yearIndex)) \(monthName)")
        }
        
        func getDayOfWeek(from givenDate: Date) -> String {
            let index = Calendar.current.component(.weekday, from: givenDate)
            return Calendar.current.weekdaySymbols[index - 1]
        }
    }
}

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
                    
                    CustomSection(header: viewModel.sectionHeader(y: yearIndex, m: monthIndex)) {
                        ForEach(viewModel.unavailableDatesfilteredBy(year: yearIndex, month: monthIndex, from: doctorData.unavailability), id: \.self) { unavailableDate in
                            HStack {
                                Text(unavailableDate, style: .date).deleteDisabled(!isSectionEditable)
                                    .foregroundColor(.primary)
                                Text(viewModel.getDayOfWeek(from: unavailableDate))
                                    .foregroundColor(.secondary)
                            }
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
