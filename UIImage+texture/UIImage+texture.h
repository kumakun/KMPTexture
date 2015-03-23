//
//  UIImage+texture.h
//  KPMTexture
//
//  Created by lan on 3/23/15.
//  Copyright (c) 2015 kumapower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (texture)

- (UIImage *)unTrimmedSliceWithFrameInfo:(NSDictionary *)frameInfo;

- (UIImage *)trimmedSliceWithFrameInfo:(NSDictionary *)frameInfo;

- (CGPoint) getSourceOrigin;
- (CGSize) getSourceSize;

@end
