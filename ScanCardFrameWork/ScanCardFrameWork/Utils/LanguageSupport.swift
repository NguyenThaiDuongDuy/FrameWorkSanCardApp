//
//  LanguageSupport.swift
//  ScanCard
//
//  Created by admin on 23/04/2021.
//
import Foundation

class Language {

    private init() {}
    var isEnglish: Bool = true
    static let share = Language()

    func localized(string: String) -> String {
        NSLocalizedString(string,
                          tableName: isEnglish ? "English" : "Vietnamese",
                          bundle: .main,
                          value: string,
                          comment: string)
    }
}
