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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - camera stuff

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
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
@end
