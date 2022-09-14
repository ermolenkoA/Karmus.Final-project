//
//  ChatModels.swift
//  Karmus
//
//  Created by VironIT on 9/11/22.
//

import UIKit
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var isRead: Bool
}

struct MessageModel {
    var sender: String
    var sentDate: Date
    var messageText: String
    var isRead: Bool
}
