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
    
    func RegistrationMessageWithCode(name: String) -> (messageBody: String, code: String){
        ("Karmus\n\nЗдравствуйте, \(name).\nВаш код для завершения регистрации: ", self.randomCode)
    }
    
    func PasswordResetMessageWithCode(name: String) -> (messageBody: String, code: String){
        ("Karmus\n\nЗдравствуйте, \(name).\nВаш код для восстановления пароля: ", self.randomCode)
    }
}

