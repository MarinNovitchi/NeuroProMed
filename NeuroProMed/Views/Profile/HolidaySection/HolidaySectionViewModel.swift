//
//  HolidaySectionViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension HolidaySection {
    
    @MainActor
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
        
        func sectionHeader(y yearIndex: Int, m monthIndex: Int) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.monthSymbols[monthIndex - 1]
            
            return "\(String(yearIndex)) \(monthName)"
        }
        
        func getDayOfWeek(from givenDate: Date) -> String {
            let index = Calendar.current.component(.weekday, from: givenDate)
            return Calendar.current.weekdaySymbols[index - 1]
        }
    }
}
