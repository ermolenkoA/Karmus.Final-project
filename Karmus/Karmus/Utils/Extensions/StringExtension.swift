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
    
    static func makeStringFromNumber(_ number: Int) -> String {
        var result = "..."

        if number >= 1000 {
            
            switch number {
            case 1_000..<10_000:
                
                if (number % 1_000)/10 != 0 {
                    result = String(number/1_000) + "," + String((number % 1_000)/10) + "k"
                } else {
                    result = String(number/1_000) + "k"
                }
        
            case 10_000..<100_000:
                
                if (number % 10_000)/100 != 0 {
                    result = String(number/10_000) + "," + String((number % 10_000)/100) + "kk"
                } else {
                    result = String(number/10_000) + "kk"
                }
                
            case 100_000..<1_000_000:
                
                if (number % 100_000)/1000 != 0 {
                    result = String(number/100_000) + "," + String((number % 100_000)/1000) + "kkk"
                } else {
                    result = String(number/100_000) + "kkk"
                }
                
            case 1_000_000..<10_000_000:
                
                if (number % 1_000_000)/10000 != 0 {
                    result = String(number/1_000_000) + "," + String((number % 1_000_000)/10000) + "M"
                } else {
                    result = String(number/1_000_000) + "M"
                }
                
            default:
                break
            }
            
        } else{
           result = String(number)
        }
        
        return result
    }
    
    static func messageDate(_ date: Date) -> String {
        
        let difference = Date().difference(from: date)
        
        if difference.year! > 0 {
            return difference.year! < 5 ? "\(difference.year!)г" : "\(difference.year!)л"
        } else if difference.month! > 0 {
            return "\(difference.month!)М"
        } else if difference.day! / 7 > 0 {
            return "\(difference.day! / 7)н"
        } else if difference.day! > 0 {
            return "\(difference.day!)д"
        } else if difference.hour! > 0 {
            return "\(difference.hour!)ч"
        } else if difference.minute! > 0 {
            return "\(difference.minute!)м"
        } else {
            return ""
        }
        
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
