//
//  CodeGenerate.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

final class Code {
    
    static var shared = Code()
    
    var randomCode: String {
        let charactersForCode = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
        var code = ""
        for _ in 1...6{
           code += String(charactersForCode.randomElement()!)
        }
        return code
    }
    
    var randomCodeNine: String {
        let charactersForCode = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789"
        var code = ""
        for _ in 1...9{
           code += String(charactersForCode.randomElement()!)
        }
        return code
    }
    
    func couponsGenerate(numberOfCoupons: UInt) -> (messageBody: String, codes: [String]) {
        var message = "Karmus\n\nЗдравствуйте, в данном сообщении мы отправляем вам созданные купоны: \n"
        
        var codes = [String]()
        
        for _ in 1..<numberOfCoupons {
            let code = randomCodeNine
            message += code + ", "
        }
        
        codes.append(randomCodeNine)
        message += codes.last!
        
        return (message, codes)
    }
    
    func registrationMessageWithCode(name: String) -> (messageBody: String, code: String) {
        ("Karmus\n\nЗдравствуйте, \(name).\nВаш код для завершения регистрации: ", self.randomCode)
    }
    
    func passwordResetMessageWithCode(name: String) -> (messageBody: String, code: String) {
        ("Karmus\n\nЗдравствуйте, \(name).\nВаш код для смены пароля: ", self.randomCode)
    }
}

