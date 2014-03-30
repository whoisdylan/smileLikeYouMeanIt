//
//  WHOMainViewController.h
//  smileLikeYouMeanIt
//
//  Created by dylan on 3/29/14.
//  Copyright (c) 2014 whoisdylan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHOMainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *smileLabel;
- (IBAction)cameraButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
