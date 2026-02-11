//
//  ContentView.swift
//  JDTuner
//
//  Created by 조동현 on 2/5/26.
//

import SwiftUI

struct ContentView: View {
  
  private let tunerWrapper = JDTunerWrapper()
  
    var body: some View {
        VStack {
            Text("JD Tuner")
        }
        .padding()
        .onAppear {
          let result = tunerWrapper.test()
          print(result)
        }
    }
}

#Preview {
    ContentView()
}
