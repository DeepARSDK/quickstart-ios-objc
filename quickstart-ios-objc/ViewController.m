//
//  ViewController.m
//  quickstart-ios-objc
//
//  Created by Luka Mijatovic on 05/12/2019.
//  Copyright © 2019 DeepAR. All rights reserved.
//

#import "ViewController.h"
#import <DeepAR/DeepAR.h>
#import <DeepAR/CameraController.h>

@interface ViewController () <DeepARDelegate>

@property (nonatomic, strong) DeepAR* deepar;
@property (nonatomic, strong) ARView* arview;
@property (nonatomic, strong) CameraController* cameraController;

@property (nonatomic, strong) NSMutableArray* masks;
@property (nonatomic, assign) NSInteger currentMaskIndex;

@property (nonatomic, strong) NSMutableArray* effects;
@property (nonatomic, assign) NSInteger currentEffectIndex;

@property (nonatomic, strong) NSMutableArray* filters;
@property (nonatomic, assign) NSInteger currentFilterIndex;

@property (nonatomic, assign) NSInteger currentMode;

@property (nonatomic, strong) IBOutlet UIButton* masksButton;
@property (nonatomic, strong) IBOutlet UIButton* effectsButton;
@property (nonatomic, strong) IBOutlet UIButton* filtersButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentEffectIndex = 0;
    
    // Instantiate ARView and add it to view hierarchy.
    self.deepar = [[DeepAR alloc] init];

    [self.deepar setLicenseKey:@"your_license_key_goes_here"];
    [self.deepar initialize];
    self.deepar.delegate = self;

    self.arview = (ARView*)[self.deepar createARViewWithFrame:[UIScreen mainScreen].bounds];
    [self.view insertSubview:self.arview atIndex:0];
    self.cameraController = [[CameraController alloc] init];
    self.cameraController.deepAR = self.deepar;

    [self.cameraController startCameraWithAudio:YES];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

    // Create the list of effects .

    self.effects = [NSMutableArray array];
    [self.effects addObject:@"none"];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"viking_helmet.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"MakeupLook.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Split_View_Look.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Emotions_Exaggerator.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Emotion_Meter.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Stallone.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"flower_face.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"galaxy_background.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Humanoid.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Neon_Devil_Horns.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Ping_Pong.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Pixel_Hearts.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Snail.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Hope.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Vendetta_Mask.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Fire_Effect.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"burning_effect.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Elephant_Trunk.deepar" ofType:@""]];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.arview.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self.deepar shutdown];
}

- (void)switchEffect:(NSMutableArray*)array index:(NSInteger)index slot:(NSString*)slot {
    if ([array[index] isEqualToString:@"none"]) {
        // To clear slot, just pass nil as the path parameter.
        [self.deepar switchEffectWithSlot:slot path:nil];
    } else {
        // Switches the effects in the slot. Path parameter is the absolute path to the effect file.
        // Slot is a way to have multiple effects active at the same time. There is no limitation to
        // the number of slots, but there can be only one active effect in one slot. If we load
        // the new effect in already occupied slot, the old effect will be removed and the new one
        // will be added.
        [self.deepar switchEffectWithSlot:slot path:array[index]];
    }
}

- (IBAction)nextEffect:(id)sender {
    self.currentEffectIndex++;
    if (self.currentEffectIndex >= self.effects.count) {
        self.currentEffectIndex = 0;
    }
    [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
}

- (IBAction)prevEffect:(id)sender {
    self.currentEffectIndex--;
    if (self.currentEffectIndex < 0) {
        self.currentEffectIndex = self.effects.count - 1;
    }
    [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
}

- (IBAction)takeScreenshot:(id)sender {
    [self.deepar takeScreenshot];
}

- (IBAction)switchCamera:(id)sender {
    self.cameraController.position = self.cameraController.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortrait) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationPortrait;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

- (void)didStartVideoRecording {

}

- (void)didFinishVideoRecording:(NSString*)videoFilePath {
    NSLog(@"didFinishVideoRecording");
}

- (void)recordingFailedWithError:(NSError*)error {
    
}

- (void)didTakeScreenshot:(UIImage*)screenshot {
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
}

- (void)didInitialize {

}

- (void)didFinishShutdown{
    
}

- (void)faceVisiblityDidChange:(BOOL)faceVisible {

}

@end
