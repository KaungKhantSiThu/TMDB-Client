//
//  Realm+Extensions.swift
//  TMDB Client
//
//  Created by Kaung Khant Si Thu on 14/11/2024.
//

import RealmSwift

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
