//
//  DeepARSharedManager.h
//  quickstart-ios-objc
//
//  Created by Kod Biro on 29/10/2020.
//  Copyright © 2020 DeepAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeepAR/DeepAR.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeepARSharedManager : NSObject

@property (nonatomic, readonly) DeepAR * deepAR;
@property (nonatomic, readonly) ARView * arview;
@property (nonatomic, readonly) CameraController * cameraController;

+ (DeepARSharedManager *) getShaderManager;

@end

NS_ASSUME_NONNULL_END
