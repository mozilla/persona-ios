//
//  PViewController.h
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <UIKit/UIKit.h>
#import "PersonaViewController.h"
#import "PPersonaControllerDelegate_iPad.h"
#import "PPersonaControllerDelegate_iPhone.h"
#import "PLoginController_iPhone.h"

#define ORIGIN @"http://www.mozilla.com"

@interface PViewController : UIViewController
{
  NSMutableData *userData;
  NSMutableDictionary* userDict;
  NSString* loggedInUser;
  
  id personaDelegate;
  PersonaViewController* personaController;
}

- (void) userLogin: (NSNotification *)notification;
- (void) userLogout: (NSNotification *)notification;

- (IBAction)login:(id)sender;

@property (nonatomic,strong) IBOutlet UILabel* currentUser;

@end
