//
//  ViewController.m
//  quickstart-ios-objc
//
//  Created by Luka Mijatovic on 05/12/2019.
//  Copyright © 2019 DeepAR. All rights reserved.
//

#import "ViewController.h"
#import <DeepAR/ARView.h>
#import <DeepAR/CameraController.h>

@interface ViewController () <DeepARDelegate>

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

    self.masksButton.backgroundColor = [UIColor lightGrayColor];
    self.effectsButton.backgroundColor = [UIColor clearColor];
    self.filtersButton.backgroundColor = [UIColor clearColor];
    self.currentMode = 0;
    self.currentMaskIndex = 0;
    self.currentEffectIndex = 0;
    self.currentFilterIndex = 0;

    
    // Instantiate ARView and add it to view hierarchy.
    self.arview = [[ARView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    [self.arview setLicenseKey:@"your_license_key_goes_here"];

    self.arview.delegate = self;
    [self.view insertSubview:self.arview atIndex:0];
    self.cameraController = [[CameraController alloc] init];
    self.cameraController.arview = self.arview;

    [self.arview initialize];
    [self.cameraController startCamera];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

    // Create the list of masks, effects and filters.
    self.masks = [NSMutableArray array];
    [self.masks addObject:@"none"];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"aviators" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"bigmouth" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"dalmatian" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"fatify" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"flowers" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"grumpycat" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"koala" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"lion" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"mudMask" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"pug" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"slash" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"sleepingmask" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"smallface" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"teddycigar" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"tripleface" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"twistedFace" ofType:@""]];

    self.effects = [NSMutableArray array];
    [self.filters addObject:@"none"];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"fire" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"heart" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"blizzard" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"rain" ofType:@""]];

    self.filters = [NSMutableArray array];
    [self.filters addObject:@"none"];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"tv80" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"drawingmanga" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"sepia" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"bleachbypass" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"realvhs" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"filmcolorperfection" ofType:@""]];
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
    [self.arview shutdown];
}

- (void)switchEffect:(NSMutableArray*)array index:(NSInteger)index slot:(NSString*)slot {
    if ([array[index] isEqualToString:@"none"]) {
        // To clear slot, just pass nil as the path parameter.
        [self.arview switchEffectWithSlot:slot path:nil];
    } else {
        // Switches the effects in the slot. Path parameter is the absolute path to the effect file.
        // Slot is a way to have multiple effects active at the same time. There is no limitation to
        // the number of slots, but there can be only one active effect in one slot. If we load
        // the new effect in already occupied slot, the old effect will be removed and the new one
        // will be added.
        [self.arview switchEffectWithSlot:slot path:array[index]];
    }
}

- (IBAction)nextEffect:(id)sender {
    
    switch (self.currentMode) {
        case 0:
            self.currentMaskIndex++;
            if (self.currentMaskIndex >= self.masks.count) {
                self.currentMaskIndex = 0;
            }
            [self switchEffect:self.masks index:self.currentMaskIndex slot:@"mask"];
            break;
        case 1:
            self.currentEffectIndex++;
            if (self.currentEffectIndex >= self.effects.count) {
                self.currentEffectIndex = 0;
            }
            [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
            break;
        case 2:
            self.currentFilterIndex++;
            if (self.currentFilterIndex >= self.filters.count) {
                self.currentFilterIndex = 0;
            }
            [self switchEffect:self.filters index:self.currentFilterIndex slot:@"filter"];
            break;
            
        default:
            break;
    }
}

- (IBAction)prevEffect:(id)sender {
    
    switch (self.currentMode) {
        case 0:
            self.currentMaskIndex--;
            if (self.currentMaskIndex < 0) {
                self.currentMaskIndex = self.masks.count - 1;
            }
            [self switchEffect:self.masks index:self.currentMaskIndex slot:@"mask"];
            break;
        case 1:
            self.currentEffectIndex--;
            if (self.currentEffectIndex < 0) {
                self.currentEffectIndex = self.effects.count - 1;
            }
            [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
            break;
        case 2:
            self.currentFilterIndex--;
            if (self.currentFilterIndex < 0) {
                self.currentFilterIndex = self.filters.count - 1;
            }
            [self switchEffect:self.filters index:self.currentFilterIndex slot:@"filter"];
            break;
            
        default:
            break;
    }
}

- (IBAction)takeScreenshot:(id)sender {
    [self.arview takeScreenshot];
}

- (IBAction)masksSelected:(id)sender {
    self.currentMode = 0;
    self.masksButton.backgroundColor = [UIColor lightGrayColor];
    self.effectsButton.backgroundColor = [UIColor clearColor];
    self.filtersButton.backgroundColor = [UIColor clearColor];
}

- (IBAction)effectsSelected:(id)sender {
    self.currentMode = 1;
    self.masksButton.backgroundColor = [UIColor clearColor];
    self.effectsButton.backgroundColor = [UIColor lightGrayColor];
    self.filtersButton.backgroundColor = [UIColor clearColor];
}

- (IBAction)filtersSelected:(id)sender {
    self.currentMode = 2;
    self.masksButton.backgroundColor = [UIColor clearColor];
    self.effectsButton.backgroundColor = [UIColor clearColor];
    self.filtersButton.backgroundColor = [UIColor lightGrayColor];
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

- (void)faceVisiblityDidChange:(BOOL)faceVisible {

}

@end
