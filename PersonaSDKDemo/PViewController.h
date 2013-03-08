//
//  PViewController.h
//  PersonaSDKDemo
//
//  Created by Dan Walkowski on 3/8/13.
//  Copyright (c) 2013 Mozilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonaViewController.h"
#import "PPersonaControllerDelegate_iPad.h"

#define ORIGIN @"http://www.mozilla.com"

@interface PViewController : UIViewController
{
  NSMutableData *userData;
  NSMutableDictionary* userDict;
  NSString* loggedInUser;
  
  PPersonaControllerDelegate_iPad* personaDelegate;
  PersonaViewController* personaController;

}

- (void) userLogin: (NSNotification *)notification;
- (void) userLogout: (NSNotification *)notification;

- (IBAction)login:(id)sender;

@end
