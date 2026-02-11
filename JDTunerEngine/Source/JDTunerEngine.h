/*
  ==============================================================================

    JDTunerEngine.h
    Created: 5 Feb 2026 8:04:56pm
    Author:  조동현

  ==============================================================================
*/

#pragma once
#import "JuceHeader.h"

class JDTunerEngine: public juce::AudioIODeviceCallback {
  public:
  JDTunerEngine();
  ~JDTunerEngine();
  
  
  // AudioIODeviceCallback를 상속하면 아래의 3개 메서드는 필수 구현
  // abstract class .. 에러가 나오면 해당 클래스의 상위 클래스에 가서
  // virtual 메서드가 = 0 인것과 이 클래스가 하는 핵심 메서드를 선언 및 구현 필요
  
  void audioDeviceIOCallbackWithContext(const float *const *inputChannelData, int numInputChannels, float *const *outputChannelData, int numOutputChannels, int numSamples, const juce::AudioIODeviceCallbackContext &context) override;
  
  void audioDeviceAboutToStart(juce::AudioIODevice *device) override;
  void audioDeviceStopped() override;
  
  float getValue();
  
  private:
  // 튜너 알고리즘 처리 후 뷰로 보낼 값
  float value;
};
