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
  
  if (jdTuner.isReady) {
    // 데이터 처리가 완료되면 등록된 콜백 실행
    if (onResultReady) {
      auto result = jdTuner.getResult();
      float clampedCents = fmaxf(-50.0f, fminf(50.0f, result.cents));
      result.cents = clampedCents;
      result.isMatched = std::abs(clampedCents) <= centsLimit;
      
      onResultReady(result);
    }
  } else {
    float sampleRate = deviceManager.getAudioDeviceSetup().sampleRate;
    jdTuner.startTuner(inputChannelData[0], numSamples, sampleRate);
  }
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}

void JDTunerEngine::setTuningMode(const std::string &modeName) {
  jdTuner.setTuningMode(modeName);
}
