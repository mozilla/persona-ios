//
//  PersonaDisplayController_iPad.h
//  PersonaTest
//
//  Created by Dan Walkowski on 10/23/12.
//  Copyright (c) 2012 Mozilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonaViewController.h"

@interface PPersonaControllerDelegate_iPad : UIViewController <UIPopoverControllerDelegate, PersonaViewControllerDelegate>
{
  UIPopoverController* loginPopover;
}

- (id)initWithContentController: (UIViewController*) contentController;
- (void) doLoginFrom:(id)uiElement;
- (void) doLogout;

@end
