// PersonaViewController.m
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "PersonaViewController.h"

NSString* const PersonaLoginNotification = @"personaLoginNotification";
NSString* const PersonaLogoutNotification = @"personaLogoutNotification";
NSString* const PersonaCancelNotification = @"personaCancelNotification";


static NSString* kPersonaSignInURL = @"https://login.persona.org/sign_in#NATIVE";

@implementation PersonaViewController


- (id)initWithOrigin:(NSString*)origin
{
    if (self = [super init])
    {
		// Initialization code here
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
		_webView.delegate = self;
		_webView.suppressesIncrementalRendering = YES;
		_webView.scrollView.scrollEnabled = NO;
		_webView.scalesPageToFit = YES;
		_webView.backgroundColor = [UIColor blackColor];
				
		self.view = _webView;
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		_origin = origin;
		[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(logout:) name: PersonaLogoutNotification object:nil];
    }
    return self;
}


//- (void) viewDidLoad
//{
//  [super viewDidLoad];
//}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  //tell the embedded uiwebview to reload the page
  [_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: kPersonaSignInURL]]];

}

//- (void) viewDidUnload
//{
//  [super viewDidUnload];
//}

- (void) logout:(NSNotification *)notification
{
  NSString* injectedCodePath = [[NSBundle mainBundle] pathForResource: @"logout_inject" ofType: @"js"];
	NSString* injection = [NSString stringWithContentsOfFile: injectedCodePath encoding:NSUTF8StringEncoding error: nil];
  
	NSString* result = [_webView stringByEvaluatingJavaScriptFromString: injection];
  if (result) NSLog(@"logout success: %@", result);
  else NSLog(@"logout failed");
}


- (void)webViewDidFinishLoad:(UIWebView *)ourWebView
{  
  // Insert the code that will setup and handle the Persona callback.
	NSString* injectedCodePath = [[NSBundle mainBundle] pathForResource: @"assertion_inject" ofType: @"js"];
	NSString* injectedCodeTemplate = [NSString stringWithContentsOfFile: injectedCodePath encoding:NSUTF8StringEncoding error: nil];
	if (injectedCodeTemplate == nil) {
		NSLog(@"failed to load assertion_inject.js");
		return;
	}
	
	NSString* injectedCode = [NSString stringWithFormat: injectedCodeTemplate, _origin];
  
	NSString* result = [ourWebView stringByEvaluatingJavaScriptFromString: injectedCode];
  if (result) NSLog(@"injection success: %@", result);
  else NSLog(@"injection failed");
}


- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}


#pragma mark -

- (void)verifyAssertion:(NSString*)assertion againstServer:(NSURL*)server completionHandler:(URLConnectionHandler)completion
{
    // POST the assertion to the verification endpoint. Then report back to our delegate about the
    // results.
  
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: server cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 5];
    
    NSString* jsonContent = [NSString stringWithFormat:@"{\"assertion\":\"%@\"}", assertion];
    
    [request setHTTPShouldHandleCookies: YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonContent dataUsingEncoding: NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
						   completionHandler:completion];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL* url = [request URL];

	// The JavaScript side (the code injected in viewDidLoad will make callbacks to this native code by requesting
	// a PersonaViewController://callbackname/callback?data=foo style URL. So we capture those here and relay
	// them to our delegate.

	if ([[[url scheme] lowercaseString] isEqualToString: @"personacallback"])
	{
		if ([[url host] isEqualToString: @"gotassertion"])
		{
			NSString* assertion = [[url query] substringFromIndex: [@"data=" length]];
			[_delegate personaViewController:self didSucceedWithAssertion:assertion];
		}
		
		else if ([[url host] isEqualToString: @"failassertion"]) {
			[_delegate personaViewController:self didFailWithReason:[[url query] substringFromIndex:[@"data=" length]]];
		}

		else if ([[url host] isEqualToString: @"logouteverywhere"]) {
			[_delegate personaViewControllerDidSucceedLogout:self];
		}

		return NO;
	}
  else if ([[[url scheme] lowercaseString] isEqualToString: @"http"] || [[[url scheme] lowercaseString] isEqualToString: @"https"])
  {
      // If the user clicked on a link that escapes the persona dialog, then we open it in Safari
      if ([[url absoluteString] isEqualToString: kPersonaSignInURL] == NO)
      {
          [[UIApplication sharedApplication] openURL: url];
          return NO;
      }
  }
	
	return YES;
}

@end
