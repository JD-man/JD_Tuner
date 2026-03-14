//
//  ContentView.swift
//  JDTuner
//
//  Created by 조동현 on 2/5/26.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - 3. 메인 뷰
struct TunerView: View {
  @State private var result: WrapperResult = WrapperResult()
  private let wrapper = JDTunerWrapper()
  
  var body: some View {
    ZStack {
      // 배경: 미세한 방사형 그라데이션
      RadialGradient(
        gradient: Gradient(colors: [Constants.bgColor.opacity(0.8), Constants.bgColor]),
        center: .center,
        startRadius: 50,
        endRadius: 400
      )
      .ignoresSafeArea()
      
      VStack(spacing: 0) {
        Spacer()
        
        ZStack {
          
          // 바깥쪽 얇은 보조 트랙
          GaugeArc(startAngle: .degrees(-Constants.gaugeSpan), endAngle: .degrees(Constants.gaugeSpan))
            .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: Constants.subLineWidth, lineCap: .round))
            .frame(width: Constants.outerTrackSize, height: Constants.outerTrackSize)
          
          // 안쪽 얇은 보조 트랙
          GaugeArc(startAngle: .degrees(-Constants.gaugeSpan), endAngle: .degrees(Constants.gaugeSpan))
            .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: Constants.subLineWidth, lineCap: .round))
            .frame(width: Constants.innerTrackSize, height: Constants.innerTrackSize)
          
          // 3. 메인 3분할 컬러 트랙 (가운데)
          Group {
            // Flat (빨강)
            GaugeArc(startAngle: .degrees(-Constants.gaugeSpan), endAngle: .degrees(-Constants.inTuneSpan))
              .stroke(Constants.flatColor, style: StrokeStyle(lineWidth: Constants.mainLineWidth, lineCap: .round))
              .modifier(NeonGlow(color: Constants.flatColor, isActive: result.cents < -wrapper.centsLimit))
            
            // In Tune (초록)
            GaugeArc(startAngle: .degrees(-Constants.inTuneSpan), endAngle: .degrees(Constants.inTuneSpan))
              .stroke(Constants.tuneColor, style: StrokeStyle(lineWidth: Constants.mainLineWidth, lineCap: .butt))
              .modifier(NeonGlow(color: Constants.tuneColor, isActive: result.isMatched))
              .zIndex(1)
            
            // Sharp (파랑)
            GaugeArc(startAngle: .degrees(Constants.inTuneSpan), endAngle: .degrees(Constants.gaugeSpan))
              .stroke(Constants.sharpColor, style: StrokeStyle(lineWidth: Constants.mainLineWidth, lineCap: .round))
              .modifier(NeonGlow(color: Constants.sharpColor, isActive: result.cents > wrapper.centsLimit))
          }
          .frame(width: Constants.mainTrackSize, height: Constants.mainTrackSize)
          
          // 4. 노트 알파벳 뷰
          Text(displayNoteName)
            .font(.system(size: 110, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: result.isMatched ? Constants.tuneColor.opacity(0.8) : .clear, radius: 30)
            .shadow(color: result.isMatched ? Constants.tuneColor : .clear, radius: 5)
          
          // 5. 인디케이터 (점 형태의 바늘)
          Triangle()
            .fill(Color.white)
            .frame(width: Constants.indicatorSize, height: Constants.indicatorSize)
            .shadow(color: .white, radius: 3)
            .shadow(color: .white.opacity(0.5), radius: 10)
            .offset(y: -(Constants.mainTrackSize / 2))
            .rotationEffect(.degrees(Double(result.cents) * 3.0))
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: result.cents)
        }
        
        .frame(width: Constants.outerTrackSize, height: Constants.outerTrackSize)
        
        Spacer()
      }
    }
    .task {
      requestMicrophonePermission()
      for await newResult in wrapper.resultsStream {
        if result != newResult {
          self.result = newResult
        }
      }
    }
  }
}

extension TunerView {
  private enum Constants {
    // UI 디자인 상수
    static let gaugeSpan: Double = 150.0 // 게이지 범위
    static let inTuneSpan: Double = 15.0  // 정음 구간 범위
    
    // 트랙 크기
    static let mainTrackSize: CGFloat = 280.0
    static let outerTrackSize: CGFloat = 320.0 // 메인보다 40 큼
    static let innerTrackSize: CGFloat = 240.0 // 메인보다 40 작음
    
    static let mainLineWidth: CGFloat = 20.0
    static let subLineWidth: CGFloat = 1.5 // 안팎 트랙의 얇은 두께
    static let indicatorSize: CGFloat = 14.0
    
    // 컬러 팔레트
    static let flatColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    static let tuneColor = Color(red: 0.2, green: 1.0, blue: 0.4)
    static let sharpColor = Color(red: 0.2, green: 0.5, blue: 1.0)
    static let bgColor = Color(red: 0.05, green: 0.05, blue: 0.07)
  }
}

// MARK: - Microphone Permission
extension TunerView {
  func requestMicrophonePermission() {
    AVAudioApplication.requestRecordPermission { granted in
      DispatchQueue.main.async {
        if granted {
          print("마이크 권한 허용됨")
        } else {
          print("마이크 권한 거부됨")
        }
      }
    }
  }
  
  // MARK: - Helpers
  private var displayNoteName: String {
    guard let name = result.noteName, !name.isEmpty, name != "---" else { return "" }
    if name.first?.isNumber == true {
      return String(name.dropFirst())
    }
    return name
  }
}
