//
//  HolidaySection.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.05.2021.
//

import SwiftUI

struct HolidaySection: View {
    
    @Binding var doctorData: Doctor.DoctorProperties
    let isSectionEditable: Bool
    
    var doctorUnavailability: [Int: [Int]] {
        let unavailabilityGroupedByYear = Dictionary(grouping: doctorData.unavailability) {
            Calendar.current.dateComponents([.year], from: $0).year ?? 1900
        }
        return unavailabilityGroupedByYear.mapValues({
            Array(Set($0.map({
                Calendar.current.dateComponents([.month], from: $0).month ?? 0
            })))
        })
    }
    
    func removeHolidays(year: Int, month: Int, at offset: IndexSet) {
        if let dateToRemove = findDate(at: offset, year: year, month: month) {
            doctorData.unavailability.removeAll(where: { $0.compare(dateToRemove) == .orderedSame })
        }
    }
    
    func findDate(at offset: IndexSet, year: Int, month: Int) -> Date? {
        let section = filterAndSortDatesArray(dates: doctorData.unavailability, year: year, month: month)
        return section[offset.first ?? -1 ]
    }
    
    func filterAndSortDatesArray(dates: [Date], year: Int, month: Int) -> [Date] {
        return dates.filter{
            let components = Calendar.current.dateComponents([.year, .month], from: $0)
            return components.month == month && components.year == year
        }.sorted(by: { $0.compare($1) == .orderedAscending })
    }
    
    func unavailableDatesfilteredBy(year: Int, month: Int) -> [Date] {
        return filterAndSortDatesArray(dates: doctorData.unavailability, year: year, month: month)
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
    
    var body: some View {
        Group {
            ForEach(doctorUnavailability.keys.sorted(), id: \.self) { yearIndex in
                ForEach(doctorUnavailability[yearIndex]!.sorted(), id: \.self) { monthIndex in
                    
                    CustomSection(header: sectionHeader(y: yearIndex, m: monthIndex)) {
                        ForEach(unavailableDatesfilteredBy(year: yearIndex, month: monthIndex), id: \.self) { unavailableDate in
                            HStack {
                                Text(unavailableDate, style: .date).deleteDisabled(!isSectionEditable)
                                    .foregroundColor(.primary)
                                Text(getDayOfWeek(from: unavailableDate))
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
        HolidaySection(doctorData: .constant(Doctor.example), isSectionEditable: true)
    }
}
