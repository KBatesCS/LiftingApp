//
//  NSSPredicate + Helper.swift
//  LiftingApp
//
//  Created by Kevin Bates on 4/17/24.
//

import Foundation

extension NSPredicate {
    static let all = NSPredicate(format: "TRUEPREDICATE")
    static let none = NSPredicate(format: "FALSEPREDICATE")
}
