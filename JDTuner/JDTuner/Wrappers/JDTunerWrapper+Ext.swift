//
//  JDTunerWrapper+Ext.swift
//  JDTuner
//
//  Created by 조동현 on 3/10/26.
//

import Foundation

// JDTunerWrapper을 AsyncStream으로 감싸기
extension JDTunerWrapper {
  var resultsStream: AsyncStream<WrapperResult> {
    AsyncStream { continuation in
      self.onResultUpdate = { result in
        guard let result else { return }
        continuation.yield(result)
      }
      continuation.onTermination = { @Sendable _ in
        self.onResultUpdate = nil
      }
    }
  }
}
