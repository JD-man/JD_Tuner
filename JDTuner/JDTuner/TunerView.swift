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
  @State
  private var result: WrapperResult = .init()
  private let wrapper = JDTunerWrapper()
  
  var body: some View {
    ZStack {
      
      Color(white: 0.1).ignoresSafeArea()
      
      VStack(spacing: 40) {
        // 1. 헤더 (상태 표시)
        Text(result.isMatched ? "PERFECT" : "TUNING...")
          .font(.caption)
          .tracking(3)
          .foregroundColor(result.isMatched ? .green : .secondary)
        
        // 2. 메인 음정 표시 (Note Name)
        VStack(spacing: -10) {
          Text(result.noteName ?? "---")
            .font(.system(size: 120, weight: .black, design: .monospaced))
            .foregroundColor(result.isMatched ? .green : .white)
            .shadow(color: result.isMatched ? .green.opacity(0.5) : .clear, radius: 20)
          
          Text(String(format: "%.1f Hz", result.frequency))
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
              .fill(result.isMatched ? Color.green : Color.red)
              .frame(width: 2, height: 30)
            
            // 움직이는 바늘
            VStack(spacing: 0) {
              Triangle()
                .fill(result.isMatched ? Color.green : Color.blue)
                .frame(width: 12, height: 12)
              Rectangle()
                .fill(result.isMatched ? Color.green : Color.blue)
                .frame(width: 2, height: 20)
            }
            .offset(x: CGFloat(result.cents) * 3) // 1센트당 3포인트 이동
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: result.cents)
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
    .onAppear {
      requestMicrophonePermission()
    }
    .task {
      // asyncstream 사용 및 실제 값 변경때만 상태값 변경
      var lastResult: WrapperResult? = nil
      for await newResult in wrapper.resultsStream {
          if newResult != lastResult {
              self.result = newResult
              lastResult = newResult
          }
      }
    }
  }
}

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
}
