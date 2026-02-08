//
//  JDTunerWrapper.m
//  JDTuner
//
//  Created by 조동현 on 2/6/26.
//

#import <Foundation/Foundation.h>
#import "JDTunerWrapper.h"
#import "JDTunerEngine.h"

@implementation JDTunerWrapper
  JDTunerEngine engine;

- (int)test: (int)value {
  return engine.process(value);
}

@end
