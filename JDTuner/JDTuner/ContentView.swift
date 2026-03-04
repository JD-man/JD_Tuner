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
  var frequency: Float = 0.0
  @State
  var note: String = ""
  @State
  var cents: Float = 0.0
  
    var body: some View {
        VStack {
            Text("\(frequency)Hz, \(note)note, \(cents)cents")
        }
        .padding()
        .onReceive(timer, perform: { _ in
          frequency = tunerWrapper.getFrequency()
          note = tunerWrapper.getNoteName()
          cents = tunerWrapper.getCents()
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
