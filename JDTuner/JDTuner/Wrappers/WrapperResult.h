//
//  WrapperResult.h
//  JDTuner
//
//  Created by 조동현 on 3/9/26.
//

#ifndef WrapperResult_h
#define WrapperResult_h

@interface WrapperResult : NSObject
@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) float cents;
@property (nonatomic, copy) NSString *noteName;
@property (nonatomic, assign) bool isMatched;
@end

#endif /* WrapperResult_h */

