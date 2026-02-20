//
//  ContentView.swift
//  JDTuner
//
//  Created by 조동현 on 2/5/26.
//

import SwiftUI
import Combine
import AVFoundation

struct ContentView: View {
  
  private let tunerWrapper = JDTunerWrapper()
  
  let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  @State
  var value: Float = 0.0
  
    var body: some View {
        VStack {
            Text("\(value)")
        }
        .padding()
        .onReceive(timer, perform: { _ in
          let value = tunerWrapper.getValue()
          self.value = value
        })
        .onAppear {
          requestMicrophonePermission()
        }
    }
}

extension ContentView {
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

#Preview {
    ContentView()
}
