//
//  AntiSpam.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import Foundation

final class AntiSpam {
    
    static var logInBanTime: String? {
        if let unlockDate = UserDefaults.standard.object(forKey: ConstantKeys.logInBlockingTime) as? Date {
            if unlockDate.isGreaterThanDate(dateToCompare: Date()){
                let timeDifference = Calendar.current.dateComponents([.hour,.minute,.second], from: Date(), to: unlockDate)
                return String(format: "%02d:%02d:%02d", timeDifference.hour!, timeDifference.minute!, timeDifference.second!)
            }
            resetUserLogInAttemps()
        } else if let lastAttempDate = UserDefaults.standard.object(forKey: ConstantKeys.logInLastAttempDate) as? Date {
            if Date().isGreaterThanDate(dateToCompare: lastAttempDate.addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)){
                resetUserLogInAttemps()
            }
        }
        return nil
    }
    
    static var verificationBanTime: String? {
    
        if let unlockDate = UserDefaults.standard.object(forKey: ConstantKeys.verificationBlockingTime) as? Date {
            if unlockDate.isGreaterThanDate(dateToCompare: Date()){
                let timeDifference = Calendar.current.dateComponents([.hour,.minute,.second], from: Date(), to: unlockDate)
                return String(format: "%02d:%02d:%02d", timeDifference.hour!, timeDifference.minute!, timeDifference.second!)
            }
            resetUserVerificationAttemps()
        } else if let lastAttempDate = UserDefaults.standard.object(forKey: ConstantKeys.verificationLastAttempDate) as? Date {
            if Date().isGreaterThanDate(dateToCompare: lastAttempDate.addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)){
                resetUserVerificationAttemps()
            }
        }
        return nil
    }
    
    static var sendingCodeBanTime: String? {
        
        if let lastAttempDate = UserDefaults.standard.object(forKey: ConstantKeys.verificationLastAttempDate) as? Date {
            let sendingCodeBanDate = lastAttempDate.addMinutes(minutesToAdd: ConstantValues.defaultTimeBetweenCodeSending)
            if sendingCodeBanDate.isGreaterThanDate(dateToCompare: Date()) {
                let timeDifference = Calendar.current.dateComponents([.minute, .second], from: Date(), to: sendingCodeBanDate)
                return String(format: "%02d:%02d", timeDifference.minute!, timeDifference.second!)
            }
        }
        return nil
    
    }
    
    static func saveNewLoginAttemp() {
        
        UserDefaults.standard.setValue(Date(), forKey: ConstantKeys.logInLastAttempDate)
        
        if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.logInAttemps) as? UInt{
            UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.logInAttemps)
            if attemps + 1 >= ConstantValues.maxLogInAttemps{
                let unlockDate = Date().addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)
                UserDefaults.standard.setValue(unlockDate, forKey: ConstantKeys.logInBlockingTime)
                return
            }
        } else {
            UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.logInAttemps)
        }
        
    }
    
    static func saveNewVerificationAttemp() {
        
        UserDefaults.standard.setValue(Date(), forKey: ConstantKeys.verificationLastAttempDate)
        
        if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.verificationAttemps) as? UInt{
            UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.verificationAttemps)
            UserDefaults.standard.setValue(UInt?(nil), forKey: ConstantKeys.codeComparisonAttemps)
            if attemps + 1 >= ConstantValues.maxVerificationAttemps {
                let unlockDate = Date().addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)
                UserDefaults.standard.setValue(unlockDate, forKey: ConstantKeys.verificationBlockingTime)
            }
        } else {
            UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.verificationAttemps)
            UserDefaults.standard.setValue(UInt?(nil), forKey: ConstantKeys.codeComparisonAttemps)
        }
        
    }
    
    static func saveNewCodeComparisonAttemp() {
        
        if let attemps = UserDefaults.standard.object(forKey: ConstantKeys.codeComparisonAttemps) as? UInt{
            UserDefaults.standard.setValue(attemps + 1, forKey: ConstantKeys.codeComparisonAttemps)
            if attemps + 1 >= ConstantValues.maxCodeComparisonAttemps{
                let unlockDate = Date().addMinutes(minutesToAdd: ConstantValues.defaultTimeBan)
                UserDefaults.standard.setValue(unlockDate, forKey: ConstantKeys.verificationBlockingTime)
                return
            } 
        } else {
            UserDefaults.standard.setValue(UInt(1), forKey: ConstantKeys.codeComparisonAttemps)
        }
        
    }
    
    static func resetUserVerificationAttemps() {
        let resetDate: Date? = nil
        UserDefaults.standard.setValue(resetDate, forKey: ConstantKeys.verificationLastAttempDate)
        UserDefaults.standard.setValue(resetDate, forKey: ConstantKeys.verificationBlockingTime)
        UserDefaults.standard.setValue(UInt?(nil), forKey: ConstantKeys.verificationAttemps)
        UserDefaults.standard.setValue(UInt?(nil), forKey: ConstantKeys.codeComparisonAttemps)
    }
    
    
    static func resetUserLogInAttemps() {
        let resetDate: Date? = nil
        UserDefaults.standard.setValue(resetDate, forKey: ConstantKeys.logInLastAttempDate)
        UserDefaults.standard.setValue(resetDate, forKey: ConstantKeys.logInBlockingTime)
        UserDefaults.standard.setValue(UInt?(nil), forKey: ConstantKeys.logInAttemps)
    }
}

