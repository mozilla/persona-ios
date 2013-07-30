//
//  PViewController.m
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "PViewController.h"
#import "PLoginController_iPhone.h"

@interface PViewController ()

@end

@implementation PViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupPersonaEventHandlers];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Persona ///////////////////////////////////////////////////////////////////////////////////////////
- (void) userLogin:(NSNotification *)notification
{
  //The 'personaLoginMessage' is received when a response comes back from the verification server.
  // If you are simply returning the verification receipt, note that it may contain a FAILURE, and not an actual login id.
  // If you are instead returning your own response, from your custom server, then it is up to you to indicate errors.
  
  //This sample snippet assumes the receipt came directly from, or was forwarded from the Persona Verification server
  NSDictionary* verificationServerResponse = [notification userInfo];
  
  if ([[verificationServerResponse objectForKey:@"status"] isEqualToString:@"okay"])
  {
    loggedInUser = [verificationServerResponse objectForKey:@"email"];
    _currentUser.text = loggedInUser;

    NSLog(@"Logged In: %@", loggedInUser);
    NSLog(@"Full receipt: %@", verificationServerResponse);
    //And now do all the normal work of loading the logged-in user's content and displaying it.
    //for example, get the data for the user, using the cookie
    userData = [NSMutableData data];
    NSMutableURLRequest* userReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8090"]];
    
    [userReq setValue:[verificationServerResponse objectForKey:@"cookie"] forHTTPHeaderField:@"Cookie"];
    
    id conn = [[NSURLConnection alloc] initWithRequest:userReq delegate:self startImmediately: YES];
    if (!conn) NSLog(@"error creating userData request");
  }
  else if ([[verificationServerResponse objectForKey:@"status"] isEqualToString:@"failure"])
  {
    //Uh oh, a problem
    NSLog(@"login failed: %@", [verificationServerResponse objectForKey:@"reason"] );
    //Display an alert, etc.
  }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[userData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[userData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	userData = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  NSError* decodingError = nil;
  userDict = [NSJSONSerialization JSONObjectWithData: userData options: NSJSONReadingMutableContainers error: &decodingError];
}


- (IBAction)login:(id)sender
{
  personaController = [[PersonaViewController alloc] initWithOrigin:ORIGIN ];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  {
    personaDelegate = [[PPersonaControllerDelegate_iPad alloc] initWithContentController:personaController];
    [personaDelegate doLoginFrom:sender];
  }
  else
  {
    personaDelegate = [[PPersonaControllerDelegate_iPhone alloc] initWithContentController:personaController];
    [personaDelegate doLoginFrom:self];
  }

  personaController.delegate = personaDelegate;


}

- (IBAction)logout
{
  [personaDelegate doLogout];
}


- (void) userLogout:(NSNotification *)notification
{
  //The 'personaLogoutMessage' is received when a logout call was made to the PersonaLoginController, and the local Persona state has been cleared.
  // You should now clear any app-specific login state (cookies, etc.) and reset the user interface to default.
  NSLog(@"ViewController received user logout notification");
  _currentUser.text = nil;
  userDict = nil;
  
}

- (void) setupPersonaEventHandlers
{ 
  //Set up notification handlers for login and logout
  [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(userLogin:) name: PersonaLoginNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(userLogout:) name: PersonaLogoutNotification object:nil];
}

@end
