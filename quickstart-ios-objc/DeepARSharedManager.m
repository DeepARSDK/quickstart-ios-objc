//
//  DeepARSharedManager.m
//  quickstart-ios-objc
//
//  Created by Kod Biro on 29/10/2020.
//  Copyright © 2020 DeepAR. All rights reserved.
//

#import "DeepARSharedManager.h"

@implementation DeepARSharedManager


+ (DeepARSharedManager *)getShaderManager
{
    static DeepARSharedManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DeepAR * deepAR = [DeepAR new];
        CameraController * cameraController = [CameraController new];
        
        [deepAR setLicenseKey:@"your_licence_key_here"];
        
        CGRect arviewrect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        ARView * arview = (ARView*)[deepAR createARViewWithFrame:arviewrect];
        
        cameraController.deepAR = deepAR;
        cameraController.preset = AVCaptureSessionPreset1920x1080;
        cameraController.videoOrientation = AVCaptureVideoOrientationPortrait;
        [cameraController startCamera];
        
        manager = [[self alloc] init:deepAR ARView:arview CameraController:cameraController];
    });
    return manager;
}

- (instancetype)init:(DeepAR *)deepAR ARView:(ARView *)arview CameraController:(CameraController *)cameraController;
{
    self = [super init];
    if (self) {
        _deepAR = deepAR;
        _arview = arview;
        _cameraController = cameraController;
    }
    return self;
}



@end
