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
  @State private var selectedMode: TuningMode = .guitarStandard
  private let wrapper = JDTunerWrapper()
  
  var body: some View {
    ZStack {
      // 배경: 미세한 방사형 그라데이션
      RadialGradient(
        gradient: Gradient(colors: [Constants.bgColor.opacity(0.8), Constants.bgColor]),
        center: .top,
        startRadius: 30,
        endRadius: 400
      )
      .ignoresSafeArea()
      
      VStack(spacing: 0) {
        Spacer()
        
        ZStack {
          
          // 바깥쪽 메탈릭 원형 트랙
          ZStack {
            // 1-1. 베이스 컬러 그라데이션 트랙 + 입체 그림자
            GaugeArc(startAngle: .degrees(-Constants.gaugeSpan), endAngle: .degrees(Constants.gaugeSpan))
              .stroke(metallicGradient, style: StrokeStyle(lineWidth: Constants.outerTrackWidth, lineCap: .round))
            
            // 1-2. 메탈 질감 하이라이트 (상단 빛 반사 효과)
            GaugeArc(startAngle: .degrees(-Constants.gaugeSpan), endAngle: .degrees(Constants.gaugeSpan))
              .stroke(
                LinearGradient(colors: [.white.opacity(0.4), .clear, .black.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: Constants.outerTrackWidth, lineCap: .round)
              )
              .blendMode(.overlay) // 색상 위에 자연스럽게 섞이도록
          }
          .opacity(0.3)
          .frame(width: Constants.outerTrackSize, height: Constants.outerTrackSize)
          
          
          // 안쪽 메탈릭 원형 트랙
          ZStack {
            // 2-1. 베이스 컬러 그라데이션 원 + 입체 그림자
            Circle()
              .stroke(innerMetallicGradient, lineWidth: Constants.innerTrackWidth)
            
            // 2-2. 메탈 질감 베젤 효과 (좌측 상단 하이라이트, 우측 하단 쉐도우)
            Circle()
              .strokeBorder( // strokeBorder를 써야 원 안쪽에 테두리가 생김
                LinearGradient(
                  gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.7), location: 0.1), // 빛 받는 부분
                    .init(color: Color.white.opacity(0.1), location: 0.5),
                    .init(color: Color.gray.opacity(0.4), location: 0.9)  // 그림자 지는 부분
                  ]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 2 // 얇은 베젤 선
              )
          }
          .opacity(0.5)
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
            .zIndex(1)
        }
        .frame(width: Constants.outerTrackSize, height: Constants.outerTrackSize)
        
        HStack {
          Text("Tuning Mode")
            .font(.headline)
            .foregroundColor(.white.opacity(0.6))
          
          Spacer()
          
          Picker("Tuning Mode", selection: $selectedMode) {
            ForEach(TuningMode.allCases, id: \.self) { mode in
              Text(mode.displayName).tag(mode)
            }
          }
          .pickerStyle(.menu)
          .tint(.white)
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)
          // 값이 변경될 때마다 C++ Wrapper로 전달
          .onChange(of: selectedMode, initial: false, { oldValue, newValue in
            if oldValue != newValue {
              wrapper.setTuningMode(newValue.rawValue)
            }
          })
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        
#if DEBUG
        VStack(spacing: 15) {
          
          // Slider 값과 result.cents를 강제로 연결(Binding)
          Slider(value: Binding(
            get: { Double(result.cents) },
            set: { newValue in
              let dummyResult = WrapperResult()
              dummyResult.cents = Float(newValue)
              dummyResult.isMatched = abs(newValue) <= Double(wrapper.centsLimit)
              dummyResult.noteName = "E"
              self.result = dummyResult
            }
          ), in: -50...50)
          .tint(result.isMatched ? .green : .blue)
          
          Text(String(format: "현재 Cents: %+.1f", result.cents))
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white.opacity(0.8))
          
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
#endif
        
        Spacer()
      }
    }
    .task {
      requestMicrophonePermission()
      wrapper.setTuningMode(selectedMode.rawValue)
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
    static let outerTrackSize: CGFloat = 330.0 // 메인보다 40 큼
    static let innerTrackSize: CGFloat = 230.0 // 메인보다 40 작음
    
    static let mainLineWidth: CGFloat = 20.0
    static let innerTrackWidth: CGFloat = 2.0 // 안팎 트랙의 얇은 두께
    static let outerTrackWidth: CGFloat = 1.5 // 안팎 트랙의 얇은 두께
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
  
  // 12시 방향이 초록색이 되도록 -90도 회전시킴
  private var metallicGradient: AngularGradient {
    AngularGradient(gradient: Gradient(colors: [Constants.flatColor, Constants.tuneColor, Constants.sharpColor]), center: .center, angle: .degrees(90))
  }
  
  private var innerMetallicGradient: AngularGradient {
    AngularGradient(
      gradient: Gradient(stops: [
        .init(color: .gray, location: 0.0),
        .init(color: .gray, location: 0.1),
        .init(color: Constants.flatColor, location: 0.3),
        .init(color: Constants.tuneColor, location: 0.5),
        .init(color: Constants.sharpColor, location: 0.7),
        .init(color: .gray, location: 0.9),
        .init(color: .gray, location: 1.0)
      ]),
      center: .center,
      startAngle: .degrees(90),
      endAngle: .degrees(450)
    )
  }
}
