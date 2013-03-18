//
//  PersonaDisplayController_iPhone.h
//  PersonaTest
//
//  Created by Dan Walkowski on 10/23/12.
//  Copyright (c) 2012 Mozilla. All rights reserved.
//

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
