//
//  Triangle.swift
//  JDTuner
//
//  Created by 조동현 on 3/8/26.
//

import SwiftUI

// 바늘 모양을 위한 삼각형 Custom Shape
struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.closeSubpath()
    return path
  }
}
