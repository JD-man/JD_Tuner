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
  
  // 버퍼가 전부 쌓인 경우에만 튜너 알고리즘 동작
  if (collector.size() < collectorSize) {
    collectData(inputChannelData[0], numSamples);
  } else {
    // 튜너 알고리즘 - YIN 알고리즘
    // 현재 소리를 복사해서 아주 살짝(tau) 옆으로 밀어낸 소리와 원본 소리의 차이를 빼서 제곱
    // 두 소리 겹치는 부분에서 차이 값이 최소가 되는데 그 간격으로 주파수를 계산
    
    auto prevDifference = setDiffernce(collector);
    auto normalizedDifference = normalize(prevDifference);
    auto pitchTau = findTau(normalizedDifference);
    auto frequency = getFrequency(pitchTau);
    sendFrequency(frequency);
  }
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}

// 1. 입력 데이터 모으기
void JDTunerEngine::collectData(const float* datas, int numSamples) {
  for (int i = 0; i < numSamples; ++i) {
    collector.push_back(datas[i]);
  }
}

/*
 2-1. 차이 함수
 현재 소리와 옆으로 밀어낸 소리의 차이 제곱을 difference vector에 담음
 보통 샘플의 절반까지만 밀어낸다
 */
std::vector<float> JDTunerEngine::setDiffernce(std::vector<float>& collector) {
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
  return difference;
}


/*
 2-2. 정규화
 difference의 맨 첫값은 자기 자신과의 차이이므로 무조건 0이다. 우선 여기를 제외하기 위해 1로 만들어 준다.
 소리가 작을 때는 오차도 작게 나와서, 가짜 최저값에 속을 수 있다.
 각 위치의 오차를 그전까지 나왔던 오차들의 평균값으로 나눠버립니다.
 이렇게 하면 소리 크기와 상관없이 진짜 최저값이 어디인지 훨씬 선명하게 드러난다.
 0~2 사이 값으로 정규화된다.
 */
std::vector<float> JDTunerEngine::normalize(std::vector<float>& prevDifference) {
  auto normalizedDifference = prevDifference;
  // 1. 첫 번째 칸은 1로 고정 (자기 자신과의 차이는 무의미하므로)
  normalizedDifference[0] = 1.0f;

  float runningSum = 0.0f;
  for (int tau = 1; tau < collectorSize / 2; ++tau)
  {
    // 지금까지의 차이값들을 계속 더함
    runningSum += normalizedDifference[tau];
    // 현재 값을 지금까지의 차이값의 평균으로 나눠서 정규화.
    normalizedDifference[tau] = normalizedDifference[tau] / (runningSum / (float)tau);
  }
  return normalizedDifference;
}

// 2-3. 가장 낮은 값 찾기
int JDTunerEngine::findTau(std::vector<float>& normalizedDifference) {
  int pitchTau = -1; // 우리가 찾을 음정의 간격(Tau)
  
  for (int tau = 1; tau < collectorSize / 2; ++tau)
  {
    // 1. 임계값보다 낮은 첫번째 지점
    // 전체 값에서 가장 낮은 지점을 찾으면 안된다.
    // 기타는 배음이 있기 때문에 여러 주파수가 섞여 있다.
    // 따라서 가장 강한 소리를 내는 주파수를 찾기 위해 첫번째 값을 찾는다.
    
    if (normalizedDifference[tau] < threshold)
    {
      // 2. 단순히 낮은 게 아니라, '골짜기(가장 낮은 점)'인지 확인
      // 다음 칸이 나보다 크다면, 지금 여기가 제일 낮은 곳
      if (tau + 1 < collectorSize / 2 && normalizedDifference[tau] < normalizedDifference[tau + 1])
      {
        pitchTau = tau;
        break;
      }
    }
  }
  return pitchTau;
}

// 2-4. 주파수 계산
// pitchTau 값은 검출한 파형의 주기에 해당한다.
// 샘플레이트 값을 이 값으로 나눠서 1초에 몇번 반복되는지 값인 주파수를 찾는다.
float JDTunerEngine::getFrequency(int pitchTau) {
  float frequency = 0.0f;
  if (pitchTau > 0)
  {
    float sampleRate = deviceManager.getAudioDeviceSetup().sampleRate;
    frequency = sampleRate / (float)pitchTau;
  }
  return frequency;
}

// 3. 마지막으로 이 값을 value로 전달
void JDTunerEngine::sendFrequency(float frequency) {
  
  this->value = frequency;
  collector.clear();
  juce::Logger::writeToLog(std::to_string(frequency));
}

float JDTunerEngine::getValue() {
  return value;
}
