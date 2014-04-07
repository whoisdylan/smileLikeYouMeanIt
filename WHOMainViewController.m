//
//  WHOMainViewController.m
//  smileLikeYouMeanIt
//
//  Created by dylan on 3/29/14.
//  Copyright (c) 2014 whoisdylan. All rights reserved.
//

#import "WHOMainViewController.h"
#import <CoreImage/CoreImage.h>

@interface WHOMainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *noFilter;
@end

@implementation WHOMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.filter = [[GPUImageiOSBlurFilter alloc] init];
//    self.filter = [[GPUImageBoxBlurFilter alloc] init];
    [(GPUImageiOSBlurFilter *)self.filter setBlurRadiusInPixels:5.0];
    [(GPUImageiOSBlurFilter *)self.filter setSaturation:1.15];
//    [(GPUImageBoxBlurFilter *)self.filter setBlurRadiusInPixels:10.0];
//    GPUImageOutput<GPUImageInput>* satFilter = [[GPUImageSaturationFilter alloc] init];
//    self.noFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, .125, 1.0, .75)];
    self.noFilter = [[GPUImageBrightnessFilter alloc] init];
    [self.videoCamera addTarget:self.filter];
    [self.videoCamera addTarget:self.noFilter];
    GPUImageView* filterView = (GPUImageView *)self.gpuImageView;
//    [satFilter addTarget:self.filter];
    [self.filter addTarget:filterView];
    
    [self.videoCamera startCameraCapture];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processFrame) userInfo:nil repeats:YES];
}

- (void)processFrame2 {
    [self.noFilter useNextFrameForImageCapture];
    UIImage *processedImage = [self.noFilter imageFromCurrentFramebuffer];
    [self.videoCamera pauseCameraCapture];
        //set up smile detector
        CIContext* context = [CIContext contextWithOptions:nil];
        CIDetector* smileDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        //note: use orientation 5 for regular camera images
    NSArray* features = [smileDetector featuresInImage:[CIImage imageWithCGImage:[processedImage CGImage]] options:@{CIDetectorSmile:@YES, CIDetectorImageOrientation:@1}];
        //        NSLog(@"number of features = %lu", (unsigned long)[features count]);
        if (([features count] > 0) && (((CIFaceFeature *) features[0]).hasSmile)) {
            self.smileLabel.text = @":]";
        }
        else {
            self.smileLabel.text = @":[";
        }
    [self.videoCamera resumeCameraCapture];
}

- (void)processFrame {
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:self.noFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        
        //set up background thread
        dispatch_queue_t backgroundQueue = dispatch_queue_create("backgroundQueue", 0);
        
        dispatch_async(backgroundQueue, ^{
            //set up smile detector
            CIContext* context = [CIContext contextWithOptions:nil];
            CIDetector* smileDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
            //note: use orientation 5 for regular camera images
            NSArray* features = [smileDetector featuresInImage:[CIImage imageWithCGImage:[processedImage CGImage]] options:@{CIDetectorSmile:@YES, CIDetectorImageOrientation:@1}];
            //        NSLog(@"number of features = %lu", (unsigned long)[features count]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (([features count] > 0) && (((CIFaceFeature *) features[0]).hasSmile)) {
                    self.smileLabel.text = @":]";
                }
                else {
                    self.smileLabel.text = @":[";
                }
            });

        });
        
        //to save image:
//        NSData *dataForPNGFile = UIImageJPEGRepresentation(processedImage, 0.8);
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSError *error2 = nil;
//        if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:@"FilteredPhoto.jpg"] options:NSAtomicWrite error:&error2])
//        {
//            return;
//        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - camera stuff

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
//    self.imageView.image = image;
    
    //set up smile detector
    CIContext* context = [CIContext contextWithOptions:nil];
    CIDetector* smileDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray* features = [smileDetector featuresInImage:[CIImage imageWithCGImage:[image CGImage]] options:@{CIDetectorSmile:@YES, CIDetectorImageOrientation:@5}];
    NSLog(@"number of features = %lu", (unsigned long)[features count]);
    if (([features count] > 0) && (((CIFaceFeature *) features[0]).hasSmile)) {
        self.smileLabel.text = @":]";
    }
    else {
        self.smileLabel.text = @":[";
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraButton:(UIButton *)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:nil];
}
*/
@end