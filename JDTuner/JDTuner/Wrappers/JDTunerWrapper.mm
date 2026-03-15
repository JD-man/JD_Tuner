//
//  JDTunerWrapper.m
//  JDTuner
//
//  Created by 조동현 on 2/6/26.
//

#import <Foundation/Foundation.h>
#import "JDTunerWrapper.h"
#import "JDTunerEngine.h"

@implementation JDTunerWrapper {
  // 인터페이스가 아닌 구현부 내부에 선언하여 엔진 부분을 가려 캡슐화
  // std::unique_ptr를 쓰면 메모리 관리가 자동으로 되어 안전
  std::unique_ptr<JDTunerEngine> engine;
  float smoothedFrequency;
  float smoothedRate;
  float smootedLimit;
}

// 초기화 메서드
// instancetype: 이 메서드를 부른 타입과 동일한 타입
- (instancetype)init {
  self = [super init];
  
  // 인스턴스 초기화 확인 방어코드
  if (self) {
    // 엔진 객체를 생성합니다.
    static juce::ScopedJuceInitialiser_GUI guiInitialiser;
    engine = std::make_unique<JDTunerEngine>();
    _centsLimit = 5.0;
    smoothedFrequency = 0.0;
    smoothedRate = 0.8;
    smootedLimit = 20.0;
    
    // 튜너쪽 콜백 정의
    __weak typeof(self) weakSelf = self;
    engine->onResultReady = [weakSelf](TunerResult tunerResult) {
      [weakSelf getTunerResult:tunerResult];
    };
  }
  return self;
}

- (void)getTunerResult: (TunerResult) tunerResult {
  WrapperResult *result = [WrapperResult new];
  [self smoothFrequency:tunerResult.frequency];
  
  result.frequency = smoothedFrequency;
  float clampedCents = fmaxf(-50.0f, fminf(50.0f, tunerResult.cents));
  result.cents = clampedCents;
  result.noteName = [NSString stringWithUTF8String:tunerResult.noteName.c_str()];
  result.isMatched = std::abs(clampedCents) <= _centsLimit;
  
  // 튜너로 값을 받아 뷰로 넘긴다
  if (_onResultUpdate) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self->_onResultUpdate(result);
    });
  }
}

- (void)smoothFrequency: (float) currentFrequency {
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

@end
