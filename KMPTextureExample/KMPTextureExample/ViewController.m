//
//  ViewController.m
//  KMPTextureExample
//
//  Created by lan on 3/23/15.
//  Copyright (c) 2015 kumapower. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+texture.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"aaa.json"];
    NSError *error;
    NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    //    NSLog(@"%@", json);
    
    UIImage *atlas = [UIImage imageNamed:@"aaa.png"];
    NSArray *frames = json[@"frames"];
    
    // test for unTrimmed slice
    NSDate *unTrimmedTestDate = [NSDate date];
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                              self.view.bounds.origin.y,
                                                              self.view.bounds.size.width,
                                                              self.view.bounds.size.height / 2)];
    [self.view addSubview:upView];
    for (NSDictionary *frame in frames) {
        UIImage *slice = [atlas unTrimmedSliceWithFrameInfo:frame];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:slice];
        imageview.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.6 alpha:0.5];
        [upView addSubview:imageview];
    }
    NSLog(@"unTrimmed time test %f", [[NSDate date] timeIntervalSinceDate:unTrimmedTestDate]);
    
    //test for trimmed slice
    NSDate *trimmedTestDate = [NSDate date];
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                self.view.bounds.origin.y + self.view.bounds.size.height / 2,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height / 2)];
    [self.view addSubview:downView];
    for (NSDictionary *frame in frames) {
        UIImage *slice = [atlas trimmedSliceWithFrameInfo:frame];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:slice];
        CGRect imageViewFrame = CGRectMake([slice getSourceOrigin].x, [slice getSourceOrigin].y, slice.size.width, slice.size.height);
        imageview.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.6 alpha:0.5];
        imageview.frame = imageViewFrame;
        [downView addSubview:imageview];
    }
    NSLog(@"trimmed time test %f", [[NSDate date] timeIntervalSinceDate:trimmedTestDate]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
