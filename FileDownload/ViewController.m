//
//  ViewController.m
//  FileDownload
//
//  Created by Yuanhai on 21/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "ViewController.h"
#import "LFDownloadImageView.h"
#import "LFDownloadAudioView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float imageWidth = 300.0f;
    float imageHeight = 200.0f;
    LFDownloadImageView *imageView = [[LFDownloadImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageWidth) / 2, (self.view.frame.size.height * 0.7 - imageWidth) / 2, imageWidth, imageHeight)];
    imageView.imageURL = @"http://otehyz17s.bkt.clouddn.com/image/room3.jpg";
    imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView];
    
    float audioHeight = 60.0f;
    float audioSpacing = 15.0f;
    LFDownloadAudioView *audioView = [[LFDownloadAudioView alloc] initWithFrame:CGRectMake(audioSpacing, imageView.frame.origin.y + imageView.frame.size.height + audioSpacing, self.view.frame.size.width - audioSpacing * 2, audioHeight)];
    audioView.audioURL = @"http://otehyz17s.bkt.clouddn.com/audio/lvRecord1.mp3";
    [self.view addSubview:audioView];
    
    audioView = [[LFDownloadAudioView alloc] initWithFrame:CGRectMake(audioSpacing, audioView.frame.origin.y + audioView.frame.size.height + audioSpacing, self.view.frame.size.width - audioSpacing * 2, audioHeight)];
    audioView.audioURL = @"http://otehyz17s.bkt.clouddn.com/audio/lvRecord2.mp3";
    [self.view addSubview:audioView];
    
    audioView = [[LFDownloadAudioView alloc] initWithFrame:CGRectMake(audioSpacing, audioView.frame.origin.y + audioView.frame.size.height + audioSpacing, self.view.frame.size.width - audioSpacing * 2, audioHeight)];
    audioView.audioURL = @"http://otehyz17s.bkt.clouddn.com/audio/lvRecord3.mp3";
    [self.view addSubview:audioView];
}

@end
