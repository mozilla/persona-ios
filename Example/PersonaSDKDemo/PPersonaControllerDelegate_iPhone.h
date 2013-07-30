//
//  PersonaDisplayController_iPhone.h
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <UIKit/UIKit.h>
#import "PLoginController_iPhone.h"

@interface PPersonaControllerDelegate_iPhone : UIViewController <PersonaViewControllerDelegate>
{
  PLoginController_iPhone* loginController;
}

- (id)initWithContentController: (UIViewController*) contentController;
//uiElement is ignored in the iPhone case
- (void) doLoginFrom:(id)ownerViewController;
- (void) doLogout;

@end
