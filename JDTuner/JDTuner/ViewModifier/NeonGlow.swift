//
//  NeonGlow.swift
//  JDTuner
//
//  Created by 조동현 on 3/14/26.
//

import SwiftUI

// 현재 튜닝 위치 표시하기 위한 네온 효과
struct NeonGlow: ViewModifier {
  var color: Color
  var isActive: Bool
  
  func body(content: Content) -> some View {
    content
      .shadow(color: isActive ? color.opacity(0.9) : .clear, radius: 1)
      .shadow(color: isActive ? color.opacity(0.7) : .clear, radius: 5)
      .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: 15)
      .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: 30)
  }
}
