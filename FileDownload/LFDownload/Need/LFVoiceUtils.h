//
//  LFVoiceUtils.h
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFVoiceUtils : NSObject

/** 获取播放总时间 */
+ (NSUInteger)durationWithVideo:(NSURL *)videoUrl;

@end
