//
//  Extensions.swift
//  SpotifyApp
//
//  Created by Ilona Punya on 23.03.23.
//

import Foundation
import UIKit

extension UIView {
    var width: CGFloat {
        return frame.size.width
    }
}

extension UIView {
    var height: CGFloat {
        return frame.size.height
    }
}

extension UIView {
    var left: CGFloat {
        return frame.origin.x
    }
}

extension UIView {
    var right: CGFloat {
        return left + width
    }
}

extension UIView {
    var top: CGFloat {
        return frame.origin.y
    }
}

extension UIView {
    var bottom: CGFloat {
        return top + height
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}

extension String {
    static func formattedDate(string: String) -> String {
        guard let date = DateFormatter.dateFormatter.date(from: string) else {
            return string
        }
        return DateFormatter.displayDateFormatter.string(from: date)
    }
}

extension Notification.Name {
    static let albumSavedNotification = Notification.Name("albumSavedNotification")
}
