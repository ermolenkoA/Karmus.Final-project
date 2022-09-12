//
//  ConversationProtocols.swift
//  Karmus
//
//  Created by VironIT on 9/12/22.
//

import Foundation

protocol GetConversationInfoProtocol {
    func getConversationInfo(interlocutor: ProfileForChatModel)
}

protocol GetChatIDProtocol {
    func getChatID(_ chatID: String)
}
