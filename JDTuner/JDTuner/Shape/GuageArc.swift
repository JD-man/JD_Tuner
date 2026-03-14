//
//  GuageArc.swift
//  JDTuner
//
//  Created by 조동현 on 3/14/26.
//

import SwiftUI

// Arc형 튜너 Gauge 표시 뷰
struct GaugeArc: Shape {
  var startAngle: Angle
  var endAngle: Angle
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2
    
    // SwiftUI 기준 0도(3시)를 -90도 회전시켜 12시를 0도로 기준 잡음
    path.addArc(center: center,
                radius: radius,
                startAngle: startAngle - .degrees(90),
                endAngle: endAngle - .degrees(90),
                clockwise: false)
    return path
  }
}
