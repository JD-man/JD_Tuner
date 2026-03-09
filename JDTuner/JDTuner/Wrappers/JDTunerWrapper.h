//
//  JDTunerWrapper.h
//  JDTuner
//
//  Created by 조동현 on 2/6/26.
//

#ifndef JDTunerWrapper_h
#define JDTunerWrapper_h

#import <Foundation/Foundation.h>
#import "WrapperResult.h"

// 캡슐화를 위해 swift에 공개되는 코드만 여기에 작성한다.
@interface JDTunerWrapper : NSObject

@property (nonatomic, assign) float centsLimit;

- (WrapperResult *)getTunerResult;

@end

#endif /* JDTunerWrapper_h */
