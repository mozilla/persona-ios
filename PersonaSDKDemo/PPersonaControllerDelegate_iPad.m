//
//  PersonaDisplayController_iPad.m
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "PPersonaControllerDelegate_iPad.h"


@implementation PPersonaControllerDelegate_iPad

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithContentController:(UIViewController *)contentController
{
  if (self = [super init])
  {
    CGSize loginSize = CGSizeMake(340, 440);  //hard-coded size for iPad for now
    contentController.view.frame = CGRectMake(0, 0, loginSize.width, loginSize.height);
    loginPopover = [[UIPopoverController alloc] initWithContentViewController:contentController];
    loginPopover.delegate = self;
    
    [loginPopover setPopoverContentSize:loginSize animated:YES];
  }
  return self;
}


//PersonaLoginView/////////////////

- (void) doLogout
{
  //FIX call logoutEverywhere on persona, then notify the listeners so they can blank themselves
  //Tell anyont who cares (in particular the PersonaViewController) that user wishes to logout.
  // If/when that is successful, we get the didSucceedLogout callback

  [[NSNotificationCenter defaultCenter] postNotificationName:personaLogoutMessage object:self userInfo:nil];
}


- (void) doLoginFrom:(id)uiElement
{
  //This code handles displaying the login popover from any type of UIElement.  I prefer BarButtons.
  if ([uiElement isMemberOfClass:[UIBarButtonItem class]])
  {
    [loginPopover presentPopoverFromBarButtonItem:uiElement permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
  }
  else if ([[uiElement class] isSubclassOfClass:[UIView class]])
  {
    UIView* triggerView = (UIView*)uiElement;
   [loginPopover presentPopoverFromRect:triggerView.frame inView:[triggerView superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
  }

}

- (void) popoverControllerDidDismissPopover: (UIPopoverController*) popover
{
}

- (void) personaViewControllerDidSucceedLogout: (PersonaViewController*) pvc
{
  NSLog(@"User Logged Out");
  //reset local app, clearing any login state
  
}


- (void) personaViewControllerDidCancel: (PersonaViewController*) pvc
{
  NSLog(@"User Cancelled Login");
  //reset whatever in-process login state you have. do not log user out if they are already logged in.
  
}

- (void) personaViewController: (PersonaViewController*) pvc didFailWithReason: (NSString*) reason
{
  NSLog(@"Failed: %@", reason);
  
}

- (void) personaViewController: (PersonaViewController*) pvc didSucceedWithAssertion: (NSString*) assertion
{  
  NSLog(@"Succeeded with assertion: %@", assertion);
  
  //now send the assertion to our backend, so that it can verify it with persona.org
  
  
  //This is the verification handler block, which we use to pull out the bits from the verification response
  // that we wish.  This needs to be customized to deal with whatever response your backend sends on a successful
  // verification.
  URLConnectionHandler verificationHandler = (URLConnectionHandler)^(NSHTTPURLResponse* response, NSData* data, NSError* error)
  {
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         NSLog(@"got receipt: %@", dataStr);
                         
    if (error)
    {
      [self personaViewController: pvc didFailVerificationWithError: error];
    }
    else
    {
      NSError* decodingError = nil;
      NSMutableDictionary* receipt = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &decodingError];
      
      if (decodingError)
      {
        [self personaViewController: pvc didFailVerificationWithError: decodingError];
      }
      else
      {
        //insert the cookie here, if there is one, so that the native app has access to it for direct calls
        NSDictionary* headers = [response allHeaderFields];
        NSString* cookie = [headers objectForKey:@"Set-Cookie"];
        
        if (cookie)
        {
          //copy the cookie into an easier place for the rest of the ObjC code. not necessary, just simpler
          [receipt setObject:cookie forKey:@"cookie"];
        }
        
        [self personaViewController: pvc didSucceedVerificationWithReceipt: receipt];
      }
    }
  };
  
  [pvc verifyAssertion: assertion againstServer: [NSURL URLWithString:@"http://127.0.0.1:8080"] completionHandler: verificationHandler];
  
}

- (void) personaViewController: (PersonaViewController*) pvc didSucceedVerificationWithReceipt: (NSDictionary*) receipt
{
  //NSLog(@"got receipt: %@", receipt);

  [[NSNotificationCenter defaultCenter] postNotificationName:personaLoginMessage object:self userInfo:receipt];
  
  [loginPopover dismissPopoverAnimated:TRUE];
}

- (void) personaViewController: (PersonaViewController*) pvc didFailVerificationWithError: (NSError*) error
{
  NSLog(@"Failed verification with error: %@", error);
  
  [loginPopover dismissPopoverAnimated:TRUE];

}


@end
