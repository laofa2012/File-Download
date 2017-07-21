//
//  LFVoiceUtils.m
//  RecordAndPlay
//
//  Created by Yuanhai on 18/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFVoiceUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation LFVoiceUtils

/** 获取播放总时间 */
+ (NSUInteger)durationWithVideo:(NSURL *)videoUrl
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoUrl options:opts];
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale;
    return second;
}

@end
