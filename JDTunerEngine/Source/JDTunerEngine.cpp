/*
  ==============================================================================

    JDTunerEngine.cpp
    Created: 5 Feb 2026 8:04:47pm
    Author:  조동현

  ==============================================================================
*/

#include "JDTunerEngine.h"

JDTunerEngine::~JDTunerEngine() {
  
}

void JDTunerEngine::audioDeviceIOCallbackWithContext(const float *const *inputChannelData, int numInputChannels, float *const *outputChannelData, int numOutputChannels, int numSamples, const juce::AudioIODeviceCallbackContext &context) {
  
  // 1. 입력 데이터
  const float* inLeft = inputChannelData[0];
  
  // 2. 입력된 소리의 볼륨 확인. 일정 이상일때만 튜너 알고리즘 실행 예정
  float magnitude = 0.0f;
  for (int i = 0; i < numSamples; ++i)
      magnitude += std::abs(inLeft[i]);
  
  magnitude /= (float)numSamples; // 평균 볼륨
  
  // 3. 이후 튜너 알고리즘 - YIN 알고리즘
  // 현재 소리를 복사해서 아주 살짝(tau) 옆으로 밀어낸 소리와 원본 소리의 차이를 빼서 제곱
  // 두 소리 겹치는 부분에서 차이 값이 최소가 되는데 그 간격으로 주파수를 계산
  
  // 일정 크기의 숫자 이상인 경우에만 동작
  if (magnitude >= magnitudeLimit) {
    /*
     3-1. 차이 함수
     현재 소리와 옆으로 밀어낸 소리의 차이 제곱을 difference vector에 담음
     보통 샘플의 절반까지만 밀어낸다
     */
    
    std::vector<float> difference(numSamples / 2, 0.0f);
    
    for (int tau = 0; tau < numSamples / 2; ++tau)
    {
      for (int i = 0; i < numSamples / 2; ++i)
      {
        // 현재 샘플과 tau만큼 떨어진 샘플의 차이를 구함
        float diff = inLeft[i] - inLeft[i + tau];
        difference[tau] += diff * diff; // 제곱해서 누적
      }
    }
  }
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}


float JDTunerEngine::getValue() {
  return value;
}
