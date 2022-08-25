//
//  StringExtension.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

extension String {
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    mutating func removeExtraSpaces(){
        guard !self.isEmpty else {
            return
        }

        repeat {
            guard self.starts(with: " ") else {
                break
            }
            self.removeFirst()
            
        } while !self.isEmpty
        
        guard !self.isEmpty else {
            return
        }
        
        repeat {
            
            guard self[self.index(before: self.endIndex)] == " " else {
                break
            }
            self.removeLast()
            
        } while !self.isEmpty
    }
    
}
