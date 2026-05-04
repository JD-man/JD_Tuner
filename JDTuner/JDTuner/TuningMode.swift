//
//  TuningMode.swift
//  JDTuner
//
//  Created by 조동현 on 4/23/26.
//

import Foundation

enum TuningMode: String, CaseIterable {
  case guitarStandard = "GuitarStandardE"
  case guitarDropD = "GuitarDropD"
  case bassStandard = "BassStadardE"
  
  var displayName: String {
    switch self {
    case .guitarStandard: return "Guitar Standard (E)"
    case .guitarDropD: return "Guitar Drop D"
    case .bassStandard: return "Bass Standard (E)"
    }
  }
}
