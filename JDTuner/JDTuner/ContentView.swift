//
//  ContentView.swift
//  JDTuner
//
//  Created by 조동현 on 2/5/26.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
  
  private let tunerWrapper = JDTunerWrapper()
  
    var body: some View {
        VStack {
            Text("JD Tuner")
        }
        .padding()
        .onAppear {
          requestMicrophonePermission()
          let result = tunerWrapper.test()
          print(result)
        }
    }
}

extension ContentView {
  func requestMicrophonePermission() {
    AVAudioApplication.requestRecordPermission { granted in
      DispatchQueue.main.async {
        if granted {
          print("마이크 권한 허용됨")
          // 여기서 래퍼를 통해 엔진을 초기화하거나 시작할 수 있습니다.
        } else {
          print("마이크 권한 거부됨")
        }
      }
    }
  }
}

#Preview {
    ContentView()
}
