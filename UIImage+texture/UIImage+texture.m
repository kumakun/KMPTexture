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
    CGRect sourceframe = [self sliceSourceFrameWithFrameInfo:frameInfo];
    CGRect sliceFrame = [self sliceFrameWithFrameInfo:frameInfo];
    
    //TODO: Some work for the scale factor
    UIGraphicsBeginImageContext(sourceSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClipToRect(context, sourceframe);
    
    CGContextTranslateCTM(context, 0, sourceSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    BOOL rotated = [self rotateInfoWithFrameInfo:frameInfo];
    if (rotated) {
        CGContextRotateCTM(context, 90.0 * M_PI/180.0);
        CGContextTranslateCTM(context, -sliceFrame.origin.x, -self.size.height + sliceFrame.origin.y);
        CGContextTranslateCTM(context, sourceSize.height - sourceframe.origin.y - sourceframe.size.height, -sourceframe.origin.x);
    }else{
        CGContextTranslateCTM(context, -sliceFrame.origin.x + sourceframe.origin.x, -(self.size.height - sliceFrame.origin.y - sliceFrame.size.height) + (sourceSize.height - sourceframe.origin.y - sourceframe.size.height));
    }
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    
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
    
    //TODO: Some work for the scale factor
    UIImage *slice = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:rotated ? UIImageOrientationRight : UIImageOrientationUp];
    
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
