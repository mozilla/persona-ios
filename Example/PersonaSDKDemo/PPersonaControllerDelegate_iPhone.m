//
//  PersonaDisplayController_iPhone.m
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "PPersonaControllerDelegate_iPhone.h"
#import "PLoginController_iPhone.h"

@implementation PPersonaControllerDelegate_iPhone

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithContentController:(UIViewController*)contentController
{
  if (self = [super init])
  {

    loginController = [[PLoginController_iPhone alloc] init];

    contentController.view.frame = loginController.view.frame;
    [loginController addChildViewController:contentController];
    [loginController.view addSubview:contentController.view];
  }
  return self;
}


//PersonaLoginView/////////////////

- (void) doLogout
{
  //FIX call logoutEverywhere on persona, then notify the listeners so they can blank themselves
  //Tell anyont who cares (in particular the PersonaViewController) that user wishes to logout.
  // If/when that is successful, we get the didSucceedLogout callback

  [[NSNotificationCenter defaultCenter] postNotificationName:PersonaLogoutNotification object:self userInfo:nil];
}


//uiElement is ignored in the iPhone case
- (void) doLoginFrom:(id)ownerViewController;
{
  [ownerViewController presentViewController:loginController animated:YES completion:nil];
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

  [[NSNotificationCenter defaultCenter] postNotificationName:PersonaLoginNotification object:self userInfo:receipt];
  
  [loginController dismiss];
    //CLOSE THE MODAL PAGE
}

- (void) personaViewController: (PersonaViewController*) pvc didFailVerificationWithError: (NSError*) error
{
  NSLog(@"Failed verification with error: %@", error);
  
  [loginController dismiss];

}



@end
