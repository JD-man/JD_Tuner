/*
  ==============================================================================

    JDTunerEngine.cpp
    Created: 5 Feb 2026 8:04:47pm
    Author:  조동현

  ==============================================================================
*/

#include "JDTunerEngine.h"

JDTunerEngine::JDTunerEngine() {
  
}

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
  
  // 3. 이후 튜너 알고리즘
  // 이번 작업에는 magnitude 값을 앱에 표시하는것까지
  value = magnitude;
  
  std::string log = std::to_string(magnitude);
  juce::Logger::writeToLog(log);
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}


float JDTunerEngine::getValue() {
  return value;
}
