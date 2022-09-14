//
//  MapEnumeration.swift
//  Karmus
//
//  Created by VironIT on 13.09.22.
//

import Foundation

enum State {
    case closed
    case open

    var opposite: State {
        return self == .open ? .closed : .open
    }
}
