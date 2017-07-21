//
//  LFDownloadAudioView.m
//  FileDownload
//
//  Created by Yuanhai on 21/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFDownloadAudioView.h"
#import "NSString+MD5Digest.h"
#import "LFVoiceUtils.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define Audio_Path [NSString stringWithFormat:@"%@/Audio_Path", DOCUMENTS_FOLDER]
#define Audio_File_Path(file) [NSString stringWithFormat:@"%@/%@.mp3", Audio_Path, file]

#define timeWidth 80.0f
#define minWidth 60.0f

@interface LFDownloadAudioView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *actIndicator;

@end

@implementation LFDownloadAudioView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minWidth, self.frame.size.height)];
        self.backView.backgroundColor = [UIColor colorWithRed:230 / 255.0f green:104 / 255.0f blue:54 / 255.0f alpha:1.0f];
        self.backView.layer.borderWidth = 1.0f;
        self.backView.layer.borderColor = [UIColor colorWithRed:175 / 255.0f green:132 / 255.0f blue:50 / 255.0f alpha:1.0f].CGColor;
        self.backView.layer.masksToBounds = YES;
        self.backView.layer.cornerRadius = 5.0f;
        [self addSubview:self.backView];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.backView.frame.origin.x + self.backView.frame.size.width, 0.0f, timeWidth, self.frame.size.height)];
        self.timeLabel.textColor = [UIColor blackColor];
        self.timeLabel.font = [UIFont systemFontOfSize:16.0f];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.text = @"00:00";
        [self addSubview:self.timeLabel];
        
        float imageRadius = 35.0f;
        float imageSpacing = (self.frame.size.height - imageRadius) / 2;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageSpacing, imageSpacing, imageRadius, imageRadius)];
        self.imageView.image = [UIImage imageNamed:@"AUDIO_HEAD.png"];
        [self addSubview:self.imageView];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:Audio_Path])
        {
            [fileManager createDirectoryAtPath:Audio_Path withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

- (BOOL)localExistAudio:(NSString*)fileName
{
    fileName = Audio_File_Path(fileName);
    //NSLog(@"fileName:%@", fileName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) return YES;
    return NO;
}

- (void)updateView:(NSString*)fileName
{
    fileName = Audio_File_Path(fileName);
    NSInteger duration = [LFVoiceUtils durationWithVideo:[NSURL fileURLWithPath:fileName]];
    int min = (int)(duration / 60);
    int second = (int)duration % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", [NSString stringWithFormat:@"%@%d", (min < 10 ? @"0" : @""), min], [NSString stringWithFormat:@"%@%d", (second < 10 ? @"0" : @""), second]];
    
    float totalWidth = self.frame.size.width - timeWidth;
    float realWidth = duration / 60.0f * (totalWidth - minWidth) + minWidth;
    
    self.backView.frame = CGRectMake(self.backView.frame.origin.x, self.backView.frame.origin.y, MIN(realWidth, totalWidth), self.backView.frame.size.height);
    self.timeLabel.frame = CGRectMake(self.backView.frame.origin.x + self.backView.frame.size.width, self.timeLabel.frame.origin.y, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height);
}

#pragma mark - SET

- (void)setAudioURL:(NSString *)audioURL
{
    _audioURL = audioURL;
    
    // 加密
    NSString *tmpStr = audioURL.stringByRemovingPercentEncoding;
    audioURL = [tmpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _audioURL = [audioURL MD5HexDigest];
    
    // 存在直接使用
    if ([self localExistAudio:_audioURL])
    {
        [self updateView:_audioURL];
        return;
    }
    
    // 转圈
    if (!self.actIndicator)
    {
        self.actIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect rect=self.bounds;
        self.actIndicator.frame = rect;
    }
    [self.actIndicator startAnimating];
    if (!self.actIndicator.superview) [self addSubview:self.actIndicator];
    
    // 请求
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue,^{
        __block NSMutableDictionary *fileDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        __block NSString *fileKey = _audioURL;
        __block NSData *fileData = nil;
        dispatch_sync(concurrentQueue,^{
            NSURL *url = [NSURL URLWithString:audioURL];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            NSHTTPURLResponse *urlResponse = nil;
            NSError *downloadError = nil;
            fileData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&downloadError];
            [fileDic setObject:@"" forKey:fileKey];
            if (downloadError == nil && fileData != nil && urlResponse.statusCode == 200)
            {
                if (fileData.length > 0) [fileDic setObject:@"YES" forKey:fileKey];
            }
        });
        
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.actIndicator stopAnimating];
            [self.actIndicator removeFromSuperview];
            
            // 超时或错误
            if (![[fileDic allKeys] containsObject:_audioURL]) return;
            
            // 请求结束
            if (((NSString *)fileDic[_audioURL]).length > 0)
            {
                // 写入
                [fileData writeToFile:Audio_File_Path(_audioURL) atomically:YES];
                [self updateView:_audioURL];
            }
        });
    });
}

@end
