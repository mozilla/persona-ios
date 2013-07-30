//
// PersonaViewController.m
// PersonaSDK
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


- (instancetype)initWithOrigin:(NSString*)origin {
    if (self = [super init]) {
        _origin = origin;
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(logout:) name: PersonaLogoutNotification object:nil];
    }

    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _webView.delegate = self;
    _webView.suppressesIncrementalRendering = YES;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scalesPageToFit = YES;
    _webView.autoresizesSubviews = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _webView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // tell the embedded uiwebview to reload the page
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kPersonaSignInURL]]];
}

#pragma mark - Notifications

- (void)logout:(NSNotification *)notification {
    NSString *injectedCodePath = [[NSBundle mainBundle] pathForResource: @"logout_inject" ofType: @"js"];
	NSString *injection = [NSString stringWithContentsOfFile: injectedCodePath encoding:NSUTF8StringEncoding error: nil];

	NSString *result = [_webView stringByEvaluatingJavaScriptFromString: injection];
    if (result) {
        NSLog(@"logout success: %@", result);
    } else {
        NSLog(@"logout failed");
    }
}

#pragma mark -

- (void)verifyAssertion:(NSString *)assertion againstServer:(NSURL *)server completionHandler:(URLConnectionHandler)completion {
    // POST the assertion to the verification endpoint. Then report back to our delegate about the
    // results.
  
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: server cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 5];
    
    NSString *jsonContent = [NSString stringWithFormat:@"{\"assertion\":\"%@\"}", assertion];
    
    [request setHTTPShouldHandleCookies: YES];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [jsonContent dataUsingEncoding: NSUTF8StringEncoding]];
    [request setValue: @"application/json" forHTTPHeaderField: @"content-type"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completion];
}

# pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL* url = [request URL];
    
	// The JavaScript side (the code injected in viewDidLoad will make callbacks to this native code by requesting
	// a PersonaViewController://callbackname/callback?data=foo style URL. So we capture those here and relay
	// them to our delegate.
	
	if ([[[url scheme] lowercaseString] isEqualToString: @"personacallback"]) {	
        if ([[url host] isEqualToString: @"gotassertion"]) {
            NSString *assertion = [[url query] substringFromIndex: [@"data=" length]];
            [_delegate personaViewController: self didSucceedWithAssertion: assertion];
		} else if ([[url host] isEqualToString: @"failassertion"]) {
			[_delegate personaViewController: self didFailWithReason: [[url query] substringFromIndex: [@"data=" length]]];
		} else if ([[url host] isEqualToString: @"logouteverywhere"]) {
            [_delegate personaViewControllerDidSucceedLogout: self];
        }

		return NO;
	} else if ([[[url scheme] lowercaseString] isEqualToString: @"http"] || [[[url scheme] lowercaseString] isEqualToString: @"https"]) {
        // If the user clicked on a link that escapes the persona dialog, then we open it in Safari
        if ([[url absoluteString] isEqualToString: kPersonaSignInURL] == NO) {
            [[UIApplication sharedApplication] openURL: url];
            return NO;
        }
    }
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)ourWebView {
    // Insert the code that will setup and handle the Persona callback.
	NSString *injectedCodePath = [[NSBundle mainBundle] pathForResource: @"assertion_inject" ofType: @"js"];
	NSString *injectedCodeTemplate = [NSString stringWithContentsOfFile: injectedCodePath encoding:NSUTF8StringEncoding error: nil];
    if (injectedCodeTemplate == nil) {
        NSLog(@"failed to load assertion_inject.js");
        return;
    }

	NSString *injectedCode = [NSString stringWithFormat: injectedCodeTemplate, [self origin]];
	NSString *result = [ourWebView stringByEvaluatingJavaScriptFromString:injectedCode];

    if (result) {
        NSLog(@"injection success: %@", result);
    } else {
        NSLog(@"injection failed");
    }
}

@end
