/*
  ==============================================================================

    JDTunerEngine.h
    Created: 5 Feb 2026 8:04:56pm
    Author:  조동현

  ==============================================================================
*/

#pragma once
#import "JuceHeader.h"

struct TunerResult {
  float frequency;
  const char* noteName;
  float cents;
};

class JDTunerEngine: public juce::AudioIODeviceCallback {
  public:
  
  JDTunerEngine() {
    deviceManager.initialise(1, 0, nullptr, true);
    deviceManager.addAudioCallback(this);
  }
  
  ~JDTunerEngine();
  
  
  // AudioIODeviceCallback를 상속하면 아래의 3개 메서드는 필수 구현
  // abstract class .. 에러가 나오면 해당 클래스의 상위 클래스에 가서
  // virtual 메서드가 = 0 인것과 이 클래스가 하는 핵심 메서드를 선언 및 구현 필요
  
  // deviceManager에 이 인스턴스를 addAudioCallback 해야 아래 메서드가 실행된다
  void audioDeviceIOCallbackWithContext(const float *const *inputChannelData, int numInputChannels, float *const *outputChannelData, int numOutputChannels, int numSamples, const juce::AudioIODeviceCallbackContext &context) override;
  
  void audioDeviceAboutToStart(juce::AudioIODevice *device) override;
  void audioDeviceStopped() override;
  
  TunerResult getResult();
  
  private:
  // 콜백 추가를 위한 AudioDeviceManager
  juce::AudioDeviceManager deviceManager;
  
  // 튜너 알고리즘 처리 후 뷰로 보낼 값
  TunerResult result;
  float magnitudeLimit = 0.1;
  float threshold = 0.1;
  
  std::vector<float> collector;
  const int collectorSize = 2048;
  
  void collectData(const float* datas, int numSamples);
  std::vector<float> setDiffernce(std::vector<float>& collector);
  std::vector<float> normalize(std::vector<float>& prevDifference);
  int findTau(std::vector<float>& normalizedDifference);
  float getFrequency(int pitchTau);
  TunerResult getGuitarTunerResult(float frequency);
};
