//
//  CreateNewChatConclusionProtocol.swift
//  Karmus
//
//  Created by VironIT on 9/11/22.
//

import Foundation

protocol CreateNewChatConclusionProtocol {
    func getConclusion(_ conclusion: @escaping (ProfileForChatModel, String?) -> ())
}

protocol GetChatProtocol {
    func getChat(_ chat: Chat)
}
