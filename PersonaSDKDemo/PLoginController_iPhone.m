//
//  PLoginController2_iPhone.m
//  PersonaSDKDemo
//
//  Created by Dan Walkowski on 3/12/13.
//  Copyright (c) 2013 Mozilla. All rights reserved.
//

#import "PLoginController_iPhone.h"

@interface PLoginController_iPhone ()

@end

@implementation PLoginController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      [self.view setFrame:CGRectMake(0,44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
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

//these two have differnt meanings, need to fix the plumbing
- (IBAction)cancel:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void) dismiss
{
  [self dismissViewControllerAnimated:YES completion:^(void){}];
}

@end
