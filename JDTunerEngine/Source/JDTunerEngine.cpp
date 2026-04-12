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
      smoothFrequency(result.frequency);
      result.frequency = smoothedFrequency;
      
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

void JDTunerEngine::smoothFrequency(float currentFrequency) {
  if (currentFrequency > 0.0f) {
    // 1. 처음 치거나 다른 줄을 쳐서 주파수가 크게 변했을 때 (20Hz 이상 차이) -> 즉시 반영
    if (smoothedFrequency == 0.0f || std::abs(currentFrequency - smoothedFrequency) > smootedLimit) {
      smoothedFrequency = currentFrequency;
    }
    // 2. 같은 줄의 미세한 떨림일 때 -> 부드럽게 (
    else {
      smoothedFrequency = (smoothedRate * smoothedFrequency) + ((1 - smoothedRate) * currentFrequency);
    }
  } else {
    smoothedFrequency = 0.0f;
  }
}
