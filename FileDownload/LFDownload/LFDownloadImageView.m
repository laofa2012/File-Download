//
//  LFDownloadImageView.m
//  FileDownload
//
//  Created by Yuanhai on 21/7/17.
//  Copyright © 2017年 Yuanhai. All rights reserved.
//

#import "LFDownloadImageView.h"
#import "NSString+MD5Digest.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define Image_Path [NSString stringWithFormat:@"%@/Image_Path", DOCUMENTS_FOLDER]
#define Image_File_Path(file) [NSString stringWithFormat:@"%@/%@", Image_Path, file]

@interface LFDownloadImageView ()

@property (nonatomic,   copy) NSString *defaultPath;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *actIndicator;

@end

@implementation LFDownloadImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        
        self.defaultPath = @"LFDEFAULT.jpg";
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:Image_Path])
        {
            [fileManager createDirectoryAtPath:Image_Path withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

- (UIImage *)localExistImage:(NSString*)fileName
{
    fileName = Image_File_Path(fileName);
    //NSLog(@"fileName:%@", fileName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:fileName];
        if (image && [image isKindOfClass:[UIImage class]]) return image;
    }
    return nil;
}

#pragma mark - SET

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    
    if ([imageURL rangeOfString:@"://"].location == NSNotFound)
    {
        self.imageView.image = [UIImage imageNamed:imageURL];
        return;
    }
    
    // 加密
    NSString *tmpStr = imageURL.stringByRemovingPercentEncoding;
    imageURL = [tmpStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if([imageURL length] <= 0) _imageURL = self.defaultPath;
    else _imageURL = [imageURL MD5HexDigest];
    
    // 存在直接使用
    UIImage *image = [self localExistImage:_imageURL];
    if (image)
    {
        self.imageView.image = image;
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
        __block NSString *fileKey = _imageURL;
        __block NSData *fileData = nil;
        dispatch_sync(concurrentQueue,^{
            NSURL *url = [NSURL URLWithString:imageURL];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            NSHTTPURLResponse *urlResponse = nil;
            NSError *downloadError = nil;
            fileData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&downloadError];
            [fileDic setObject:@"" forKey:fileKey];
            if (downloadError == nil && fileData != nil && urlResponse.statusCode == 200)
            {
                UIImage *image = [UIImage imageWithData:fileData];
                if (image) [fileDic setObject:image forKey:fileKey];
            }
        });
        
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.actIndicator stopAnimating];
            [self.actIndicator removeFromSuperview];
            
            // 超时或错误
            if (![[fileDic allKeys] containsObject:_imageURL]) return;
            
            // 请求结束
            UIImage *image = fileDic[_imageURL];
            if (image && [image isKindOfClass:[UIImage class]])
            {
                self.imageView.image = image;
                
                // 写入
                [fileData writeToFile:Image_File_Path(_imageURL) atomically:YES];
            }
            else
            {
                self.imageView.image = [UIImage imageNamed:self.defaultPath];
            }
        });
    });
}

@end
