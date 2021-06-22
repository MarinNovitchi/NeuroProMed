//
//  Extensions.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 18.04.2021.
//

import Foundation
import LocalAuthentication
import SwiftUI

extension Array where Element: Hashable {
    
    /// Difference between two arrays
    /// - Parameter other: The subtrahend array (containing the elements that should not be present in the result)
    /// - Returns: An array of equal or smaller size containing elements not present in the provided array
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Date {
    
    /// Set the given date to midday GMT
    /// - Returns: Same date, but set to middday GMT
    func setToMidDayGMT() -> Date {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        return Calendar.current.date(bySettingHour: 12 + secondsFromGMT / 3600 , minute: secondsFromGMT / 60 % 60, second: secondsFromGMT % 60 , of: self) ?? self
    }
}

extension String {
    
    /// Capitalize the first letter of the given string
    /// - Returns: Same string with the capitalized first letter
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Capitalize the first letter of the given string
    /// - Returns: Same string with the capitalized first letter
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension String {
    
    /// Localize the given string
    /// - Parameter comment: A description of the given text to improve the translation accuracy
    /// - Returns: The localized text
    func localize(comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

extension View {
    
    /// Get the text value of a particular app label
    /// - Parameter label: App label (e.g. for a button, header or placeholder)
    /// - Returns: The localized text value of that app label
    func label(_ label: AppLabels) -> String {
        "\(label)".localize(comment: label.rawValue)
    }
}

extension View {
    
    
    /// Create a gradient foreground of a given view
    /// - Parameters:
    ///   - start: The start unit point of the gradient
    ///   - end: The end unit point of the gradient
    ///   - colors: The array of colors for the gradient
    /// - Returns: The same view with the applied foreground gradient
    public func gradientForeground(start: UnitPoint, end: UnitPoint, colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: start,
                                    endPoint: end))
            .mask(self)
    }
}
