//
//  ContentView.swift
//  JDTuner
//
//  Created by 조동현 on 2/5/26.
//

import SwiftUI
import Combine
import AVFoundation

import SwiftUI

struct TunerView: View {
  // 실제 연결 전 테스트용 가상 데이터
  @State private var cents: Float = 0.0      // -50 ~ +50
  @State private var noteName: String = "6E"  // 현재 감지된 줄
  @State private var frequency: Float = 0.0
  @State private var isMatched: Bool = false  // 음정이 맞았는지 여부
  
  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private let wrapper = JDTunerWrapper()
  private let centsLimit: Float = 5.0
  
  var body: some View {
    ZStack {
      // 배경색 (어두운 테마가 전문 튜너 느낌을 줍니다)
      Color(white: 0.1).ignoresSafeArea()
      
      VStack(spacing: 40) {
        // 1. 헤더 (상태 표시)
        Text(isMatched ? "PERFECT" : "TUNING...")
          .font(.caption)
          .tracking(3)
          .foregroundColor(isMatched ? .green : .secondary)
        
        // 2. 메인 음정 표시 (Note Name)
        VStack(spacing: -10) {
          Text(noteName)
            .font(.system(size: 120, weight: .black, design: .monospaced))
            .foregroundColor(isMatched ? .green : .white)
            .shadow(color: isMatched ? .green.opacity(0.5) : .clear, radius: 20)
          
          Text(String(format: "%.1f Hz", frequency))
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.gray)
        }
        
        // 3. 센트 게이지 (Cents Visualizer)
        VStack {
          ZStack {
            // 게이지 배경 바
            RoundedRectangle(cornerRadius: 5)
              .fill(Color.white.opacity(0.1))
              .frame(width: 300, height: 8)
            
            // 중앙 가이드 라인 (정음 위치)
            Rectangle()
              .fill(isMatched ? Color.green : Color.red)
              .frame(width: 2, height: 30)
            
            // 움직이는 바늘
            VStack(spacing: 0) {
              Triangle()
                .fill(isMatched ? Color.green : Color.blue)
                .frame(width: 12, height: 12)
              Rectangle()
                .fill(isMatched ? Color.green : Color.blue)
                .frame(width: 2, height: 20)
            }
            .offset(x: CGFloat(cents) * 3) // 1센트당 3포인트 이동
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: cents)
          }
          
          // 하단 센트 수치 가이드
          HStack {
            Text("-50").frame(width: 40, alignment: .leading)
            Spacer()
            Text("0").foregroundColor(.secondary)
            Spacer()
            Text("+50").frame(width: 40, alignment: .trailing)
          }
          .font(.system(size: 12, design: .monospaced))
          .foregroundColor(.gray)
          .frame(width: 300)
        }
        
        Spacer()
        
//        // 4. 테스트용 컨트롤러 (나중에 삭제)
//        VStack {
//          Text("UI 테스트용 슬라이더")
//            .font(.caption).foregroundColor(.gray)
//          Slider(value: $cents, in: -50...50)
//            .accentColor(.blue)
//            .padding(.horizontal, 50)
//            .onChange(of: cents) { newValue in
//              isMatched = abs(newValue) < 3 // 3센트 이내면 초록색 변환
//            }
//        }
        .padding(.bottom, 30)
      }
      .padding(.top, 50)
    }
    .onReceive(timer) { _ in
      let currentCents = wrapper.getCents()
      self.cents = currentCents
      self.noteName = wrapper.getNoteName()
      self.frequency = wrapper.getFrequency()
      self.isMatched = abs(currentCents) <= centsLimit
    }
  }
}
