//
//  Sequence+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 18/03/23.
//

import Foundation

extension Sequence where Element: Hashable {
    internal func removeDuplicate() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Sequence where Element == StreamVariant {
    internal func removeDuplicate() -> [Element] {
        var buffer = [StreamVariant]()
        forEach { variant in
            guard let bufferItem = buffer.first(where: { $0.resolution == variant.resolution }),
                  let bufferIndex = buffer.firstIndex(where: { $0.resolution == variant.resolution }) else {
                buffer.append(variant)
                return
            }
            
            guard variant.averageBandwidth > bufferItem.averageBandwidth else { return }
            
            buffer.remove(at: bufferIndex)
            buffer.append(variant)
        }
        return buffer
    }
}
