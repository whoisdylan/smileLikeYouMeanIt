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
    
    self.filter = [[GPUImageiOSBlurFilter alloc] init];
//    self.noFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, .125, 1.0, .75)];
    self.noFilter = [[GPUImageBrightnessFilter alloc] init];
    [(GPUImageiOSBlurFilter *)self.filter setBlurRadiusInPixels:1.0];
    [self.videoCamera addTarget:self.filter];
    [self.videoCamera addTarget:self.noFilter];
    GPUImageView* filterView = (GPUImageView *)self.gpuImageView;
    [self.filter addTarget:filterView];
    
    [self.videoCamera startCameraCapture];
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processFrame) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processFrame) userInfo:nil repeats:YES];
}

- (void)processFrame2 {
    [self.videoCamera capturePhotoAsSampleBufferWithCompletionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        CIImage *processedImage = [CIImage imageWithCVPixelBuffer:CMSampleBufferGetImageBuffer(imageSampleBuffer)];
        //set up smile detector
        CIContext* context = [CIContext contextWithOptions:nil];
        CIDetector* smileDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        //note: use orientation 5 for regular camera images
        NSArray* features = [smileDetector featuresInImage:processedImage options:@{CIDetectorSmile:@YES, CIDetectorImageOrientation:@1}];
        //        NSLog(@"number of features = %lu", (unsigned long)[features count]);
        if (([features count] > 0) && (((CIFaceFeature *) features[0]).hasSmile)) {
            self.smileLabel.text = @":]";
        }
        else {
            self.smileLabel.text = @":[";
        }
    }];
}

- (void)processFrame {
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:self.noFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        
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