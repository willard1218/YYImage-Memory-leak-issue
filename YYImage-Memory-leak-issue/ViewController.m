//
//  ViewController.m
//  YYImage-Memory-leak-issue
//
//  Created by willard on 2018/2/18.
//  Copyright © 2018年 willard. All rights reserved.
//

#import "ViewController.h"
#import <YYImage/YYImage.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
    NSData *apngData = [[NSData alloc] initWithContentsOfFile:path];
    
    [self convertToGifDataFromApngData1:apngData];
//    [self convertToGifDataFromApngData2:apngData];
//    [self convertToGifDataFromApngData3:apngData];
//    [self convertToGifDataFromApngData4:apngData];
    
   
//    
    NSLog(@"done");
    sleep(5);
    NSLog(@"pop func");
}

- (void)convertToGifDataFromApngData1:(NSData *)data {
    for (NSUInteger i = 0; i < 1000; i++) {
        NSMutableArray *frameImages = [NSMutableArray array];
        NSMutableArray *frameTimeIntervals = [NSMutableArray array];
        
        [self setFrameImages:frameImages
              frameTimeIntervals:frameTimeIntervals
                        fromData:data];
        NSLog(@"%ld",i);
        NSData *gifData = [self gifDataWithFrameImages:frameImages frameTimeIntervals:frameTimeIntervals];
    }
}

- (void)convertToGifDataFromApngData2:(NSData *)data {
    for (NSUInteger i = 0; i < 1000; i++) {
        NSMutableArray *frameImages = [NSMutableArray array];
        NSMutableArray *frameTimeIntervals = [NSMutableArray array];
        
        [self setFrameImages:frameImages
          frameTimeIntervals:frameTimeIntervals
                    fromData:data];
        NSLog(@"%ld",i);
        NSData *gifData = [self _encodeWithImageIO:frameImages timeIntervals:frameTimeIntervals];
    }
}

- (void)convertToGifDataFromApngData3:(NSData *)data {
    NSMutableData *tempData = [NSMutableData new];
    for (NSUInteger i = 0; i < 1000; i++) {
        tempData.length = 0;
        NSMutableArray *frameImages = [NSMutableArray array];
        NSMutableArray *frameTimeIntervals = [NSMutableArray array];
        
        [self setFrameImages:frameImages
          frameTimeIntervals:frameTimeIntervals
                    fromData:data];
        NSLog(@"%ld",i);
        NSData *gifData = [self _encodeWithImageIO:frameImages timeIntervals:frameTimeIntervals fromData:tempData];
    }
}

- (void)convertToGifDataFromApngData4:(NSData *)data {
    for (NSUInteger i = 0; i < 1000; i++) {
        @autoreleasepool {
            NSMutableArray *frameImages = [NSMutableArray array];
            NSMutableArray *frameTimeIntervals = [NSMutableArray array];
            
            [self setFrameImages:frameImages
              frameTimeIntervals:frameTimeIntervals
                        fromData:data];
            NSLog(@"%ld",i);
            NSData *gifData = [self _encodeWithImageIO:frameImages timeIntervals:frameTimeIntervals];
        }
    }
}

- (NSData *)gifDataWithFrameImages:(NSMutableArray *)frameImages frameTimeIntervals:(NSMutableArray *)frameTimeIntervals {
    YYImageEncoder *gifEncoder = [[YYImageEncoder alloc] initWithType:YYImageTypeGIF];
    gifEncoder.loopCount = 0;
    
    for (NSUInteger i = 0 ; i < frameImages.count ; i++ )
    {
        [gifEncoder addImage:frameImages[i] duration:[frameTimeIntervals[i] doubleValue]];
    }
    
    NSData *gifData = [gifEncoder encode];
    return gifData;
}


- (NSMutableData *)_encodeWithImageIO:(NSArray <UIImage *>*)_images
                        timeIntervals:(NSArray <NSNumber *>*)_durations
                             fromData:(NSMutableData *)data {
    
    NSUInteger count =  _images.count;
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeGIF, count, NULL);
    BOOL suc = NO;
    if (destination) {
        NSDictionary *gifProperty = @{(__bridge id)kCGImagePropertyGIFDictionary:
                                          @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0)}};
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperty);
        for (int i = 0; i < count; i++) {
            @autoreleasepool {
                UIImage *imageSrc = _images[i];
                NSDictionary *frameProperty = NULL;
                frameProperty = @{(__bridge id)kCGImagePropertyGIFDictionary : @{(__bridge id) kCGImagePropertyGIFDelayTime:_durations[i]}};
                
                if ((imageSrc).CGImage)
                    CGImageDestinationAddImage(destination, imageSrc.CGImage, (__bridge CFDictionaryRef)frameProperty);
                // 將圖片加到 gif
            }
        }
        suc = CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    if (suc && data.length > 0) {
        return data;
    } else {
        
        return nil;
    }
}

- (NSMutableData *)_encodeWithImageIO:(NSArray <UIImage *>*)_images
                 timeIntervals:(NSArray <NSNumber *>*)_durations {
    NSMutableData *data = [NSMutableData new];
    NSUInteger count =  _images.count;
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeGIF, count, NULL);
    BOOL suc = NO;
    if (destination) {
        NSDictionary *gifProperty = @{(__bridge id)kCGImagePropertyGIFDictionary:
                                          @{(__bridge id)kCGImagePropertyGIFLoopCount: @0}};
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperty);
        for (int i = 0; i < count; i++) {
            @autoreleasepool {
                UIImage *imageSrc = _images[i];
                NSDictionary *frameProperty = NULL;
                frameProperty = @{(__bridge id)kCGImagePropertyGIFDictionary : @{(__bridge id) kCGImagePropertyGIFDelayTime:_durations[i]}};
                
                if ((imageSrc).CGImage)
                    CGImageDestinationAddImage(destination, imageSrc.CGImage, (__bridge CFDictionaryRef)frameProperty);
                // 將圖片加到 gif
            }
        }
        suc = CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    if (suc && data.length > 0) {
        return data;
    } else {
        return nil;
    }
}


- (void)setFrameImages:(NSMutableArray <UIImage *>*)frameImages
    frameTimeIntervals:(NSMutableArray <NSNumber *>*)frameTimeIntervals
              fromData:(NSData *)data {
    YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:1.0];
    
    for (NSUInteger i = 0 ; i < decoder.frameCount ; i++ ) {
        YYImageFrame *imageFrame = [decoder frameAtIndex:i decodeForDisplay:YES];
        UIImage *image = imageFrame.image;
        NSTimeInterval duration = imageFrame.duration;
        
        [frameImages addObject:image];
        [frameTimeIntervals addObject:@(duration)];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
