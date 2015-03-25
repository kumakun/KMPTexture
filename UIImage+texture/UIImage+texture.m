//
//  UIImage+texture.m
//  KPMTexture
//
//  Created by lan on 3/23/15.
//  Copyright (c) 2015 kumapower. All rights reserved.
//

#import "UIImage+texture.h"
#import <objc/runtime.h>

@implementation UIImage (texture)

- (CGRect)sliceFrameWithFrameInfo:(NSDictionary *)frameInfo
{
    NSDictionary *imageFrame = frameInfo[@"frame"];
    return CGRectMake([imageFrame[@"x"] doubleValue],
                      [imageFrame[@"y"] doubleValue],
                      [imageFrame[@"w"] doubleValue],
                      [imageFrame[@"h"] doubleValue]);
}

- (CGRect)sliceSourceFrameWithFrameInfo:(NSDictionary *)frameInfo
{
    NSDictionary *spriteSourceSize = frameInfo[@"spriteSourceSize"];
    return  CGRectMake([spriteSourceSize[@"x"] doubleValue],
                       [spriteSourceSize[@"y"] doubleValue],
                       [spriteSourceSize[@"w"] doubleValue],
                       [spriteSourceSize[@"h"] doubleValue]);
}

- (CGSize)sliceSourceSizeWithFrameInfo:(NSDictionary *)frameInfo
{
    NSDictionary *sourceSize = frameInfo[@"sourceSize"];
    return CGSizeMake([sourceSize[@"w"] doubleValue],
                      [sourceSize[@"h"] doubleValue]);
}

- (BOOL)rotateInfoWithFrameInfo:(NSDictionary *)frameInfo
{
    return [frameInfo[@"rotated"] boolValue];
}

- (BOOL)trimInfoWithFrameInfo:(NSDictionary *)frameInfo
{
    return [frameInfo[@"trimmed"] boolValue];
}

- (UIImage *)unTrimmedSliceWithFrameInfo:(NSDictionary *)frameInfo
{
    CGSize sourceSize = [self sliceSourceSizeWithFrameInfo:frameInfo];
    CGRect sliceFrame = [self sliceFrameWithFrameInfo:frameInfo];
    CGRect sourceFrame = [self sliceSourceFrameWithFrameInfo:frameInfo];
    BOOL rotated = [self rotateInfoWithFrameInfo:frameInfo];
    
    CGRect rotatedFrame = rotated ? CGRectMake(sliceFrame.origin.x, sliceFrame.origin.y, sliceFrame.size.height, sliceFrame.size.width) : sliceFrame;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rotatedFrame);
    
    //TODO: Some work for the scale factor
    UIGraphicsBeginImageContext(sourceSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1.0, -1.0);
    if (rotated) {
        CGContextRotateCTM(context, 90.0 * M_PI / 180.0);
        CGContextTranslateCTM(context, -sliceFrame.size.height, -sliceFrame.size.width);
    }else{
        CGContextTranslateCTM(context, 0, -sliceFrame.size.height);
    }

    CGContextDrawImage(context, CGRectMake(rotated ? -sourceFrame.origin.x : sourceFrame.origin.x,
                                           -sourceFrame.origin.y,
                                           rotatedFrame.size.width,
                                           rotatedFrame.size.height), imageRef);
    
    UIImage *slice = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return slice;
}


- (UIImage *)trimmedSliceWithFrameInfo:(NSDictionary *)frameInfo
{
    CGRect sliceFrame = [self sliceFrameWithFrameInfo:frameInfo];
    BOOL rotated = [self rotateInfoWithFrameInfo:frameInfo];
    
    CGRect rotatedFrame = rotated ? CGRectMake(sliceFrame.origin.x, sliceFrame.origin.y, sliceFrame.size.height, sliceFrame.size.width) : sliceFrame;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rotatedFrame);
    
    UIImage *slice;
    if (rotated) {
        //TODO: Some work for the scale factor
        UIGraphicsBeginImageContext(sliceFrame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextRotateCTM(context, 90.0 * M_PI / 180.0);
        CGContextTranslateCTM(context, -sliceFrame.size.height, -sliceFrame.size.width);
        
        CGContextDrawImage(context, CGRectMake(0, 0, rotatedFrame.size.width, rotatedFrame.size.height), imageRef);
        
        slice = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        //TODO: Some work for the scale factor
        slice = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    }
    
    objc_setAssociatedObject(slice, @selector(getSourceOrigin), NSStringFromCGPoint([self sliceSourceFrameWithFrameInfo:frameInfo].origin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(slice, @selector(getSourceSize), NSStringFromCGSize([self sliceSourceSizeWithFrameInfo:frameInfo]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return slice;
}


- (CGPoint) getSourceOrigin
{
    NSString *origin = objc_getAssociatedObject(self, @selector(getSourceOrigin));
    if (origin) {
        return CGPointFromString(origin);
    }else{
        return CGPointZero;
    }
    
}

- (CGSize) getSourceSize
{
    NSString *size = objc_getAssociatedObject(self, @selector(getSourceSize));
    if (size) {
        return CGSizeFromString(size);
    }else{
        return self.size;
    }
}

@end
