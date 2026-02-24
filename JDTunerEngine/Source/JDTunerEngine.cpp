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
  
  for (int i = 0; i < numSamples; ++i) {
    collector.push_back(inLeft[i]);
  }
  
//
//  // 2. 입력된 소리의 볼륨 확인. 일정 이상일때만 튜너 알고리즘 실행 예정
//  float magnitude = 0.0f;
//  for (int i = 0; i < numSamples; ++i)
//      magnitude += std::abs(inLeft[i]);
//  
//  magnitude /= (float)numSamples; // 평균 볼륨
  
  // 3. 이후 튜너 알고리즘 - YIN 알고리즘
  // 현재 소리를 복사해서 아주 살짝(tau) 옆으로 밀어낸 소리와 원본 소리의 차이를 빼서 제곱
  // 두 소리 겹치는 부분에서 차이 값이 최소가 되는데 그 간격으로 주파수를 계산
  
  // 일정 크기의 숫자 이상인 경우에만 동작
  if (collector.size() >= collectorSize) {
    /*
     3-1. 차이 함수
     현재 소리와 옆으로 밀어낸 소리의 차이 제곱을 difference vector에 담음
     보통 샘플의 절반까지만 밀어낸다
     */
    
    const float* collectedData = collector.data();
    
    std::vector<float> difference(collectorSize / 2, 0.0f);
    
    for (int tau = 0; tau < collectorSize / 2; ++tau)
    {
      for (int i = 0; i < collectorSize / 2; ++i)
      {
        // 현재 샘플과 tau만큼 떨어진 샘플의 차이를 구함
        float diff = collectedData[i] - collectedData[i + tau];
        difference[tau] += diff * diff; // 제곱해서 누적
      }
    }
    
    /*
     3-2. 정규화
     difference의 맨 첫값은 자기 자신과의 차이이므로 무조건 0이다. 우선 여기를 제외하기 위해 1로 만들어 준다.
     소리가 작을 때는 오차도 작게 나와서, 가짜 최저값에 속을 수 있다.
     각 위치의 오차를 그전까지 나왔던 오차들의 평균값으로 나눠버립니다.
     이렇게 하면 소리 크기와 상관없이 진짜 최저값이 어디인지 훨씬 선명하게 드러난다.
     0~2 사이 값으로 정규화된다.
     */
    
    // 1. 첫 번째 칸은 1로 고정 (자기 자신과의 차이는 무의미하므로)
    difference[0] = 1.0f;

    float runningSum = 0.0f;
    for (int tau = 1; tau < collectorSize / 2; ++tau)
    {
      // 지금까지의 차이값들을 계속 더함
      runningSum += difference[tau];
      // 현재 값을 지금까지의 차이값의 평균으로 나눠서 정규화.
      difference[tau] = difference[tau] / (runningSum / (float)tau);
    }
    
    // 3-3. 가장 낮은 값 찾기
    
    int pitchTau = -1; // 우리가 찾을 음정의 간격(Tau)
    
    for (int tau = 1; tau < collectorSize / 2; ++tau)
    {
      // 1. 임계값보다 낮은 첫번째 지점
      // 전체 값에서 가장 낮은 지점을 찾으면 안된다.
      // 기타는 배음이 있기 때문에 여러 주파수가 섞여 있다.
      // 따라서 가장 강한 소리를 내는 주파수를 찾기 위해 첫번째 값을 찾는다.
      
      if (difference[tau] < threshold)
      {
        // 2. 단순히 낮은 게 아니라, '골짜기(가장 낮은 점)'인지 확인
        // 다음 칸이 나보다 크다면, 지금 여기가 제일 낮은 곳
        if (tau + 1 < collectorSize / 2 && difference[tau] < difference[tau + 1])
        {
          pitchTau = tau;
          break;
        }
      }
    }
    
    // 3-4. 주파수 계산
    // pitchTau 값은 검출한 파형의 주기에 해당한다.
    // 샘플레이트 값을 이 값으로 나눠서 1초에 몇번 반복되는지 값인 주파수를 찾는다.
    
    float frequency = 0.0f;
    if (pitchTau > 0)
    {
      float sampleRate = deviceManager.getAudioDeviceSetup().sampleRate;
      frequency = sampleRate / (float)pitchTau;
    }
    
    // 4. 마지막으로 이 값을 value로 전달
    this->value = frequency;
    
    collector.erase(collector.begin(), collector.begin() + numSamples);
    if (collector.size() > 4096) collector.clear();
    
    juce::Logger::writeToLog(std::to_string(frequency));
  }
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}


float JDTunerEngine::getValue() {
  return value;
}
