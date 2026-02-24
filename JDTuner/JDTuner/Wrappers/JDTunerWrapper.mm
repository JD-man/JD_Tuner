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
}

// 초기화 메서드
// instancetype: 이 메서드를 부른 타입과 동일한 타입
- (instancetype)init {
  self = [super init];
  
  // 인스턴스 초기화 확인 방어코드
  if (self) {
    // 엔진 객체를 생성합니다.
    engine = std::make_unique<JDTunerEngine>();
  }
  return self;
}

- (float)getValue {
  // 엔진 객체 생성 확인 방어코드
  if (engine) {
    return engine->getValue();
  }
  return -1;
}

@end
