// personaViewController.h
//  PersonaSDKDemo
//
// Created by Dan Walkowski dwalkowski@mozilla.com

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <UIKit/UIKit.h>




typedef void (^URLConnectionHandler)(NSURLResponse*, NSData*, NSError*);


@class PersonaViewController;

@protocol PersonaViewControllerDelegate <NSObject>
//All of these calls are to let the delegate know that the persona controller has changed state in some way.

//Three important notifications sent by the PersonaViewController on significant events.
//They are not sent by PersonaViewController itself, but by its delegate.
//--------
//PersonaLoginNotification is sent by the delegate when a login has successfully occurred.
//Objects that need to respond to this event should register for it. Multiple occurrences are possible.
//The userInfo, for this demo application, contains the receipt, an NSData containing JSON.
extern NSString* const PersonaLoginNotification;

//PersonaLogoutNotification is sent by the delegate when a successful logout has occurred.
//Objects that need to respond to this event should register for it. Multiple occurrences are possible.
//The userInfo is nil.
extern NSString* const PersonaLogoutNotification;

//PersonaCancelNotification is sent by the delegate when cancels the login window from inside the webview.
//Objects that need to respond to this event should register for it, so that the native UI can be closed when the embedded view is.
//The userInfo is nil.
extern NSString* const PersonaCancelNotification;

//When the user clicks the cancel button in the persona dialog, this is used to inform the delegate
- (void)personaViewControllerDidCancel: (PersonaViewController*) pvc;
//When the user tells the native UI to logout, an NSNotifcation is sent to the PersonaViewController.
//When logout is finished successfully, the deldgate is signalled with this.
- (void)personaViewControllerDidSucceedLogout: (PersonaViewController*) pvc;

//When the persona controller fails to get an assertion for some reason from the backend, this is used to inform the delegate
- (void)personaViewController: (PersonaViewController*) pvc didFailWithReason: (NSString*) reason;
//When the persona controller successfully gets an assertion from the backend, this is used to inform the delegate
- (void)personaViewController: (PersonaViewController*) pvc didSucceedWithAssertion: (NSString*) assertion;
//When the persona controller successfully verifies an assertion, this is used to inform the delegate
- (void)personaViewController: (PersonaViewController*) pvc didSucceedVerificationWithReceipt: (NSDictionary*) receipt;
//When the persona controller fails to verify an assertion, this is used to inform the delegate
- (void)personaViewController: (PersonaViewController*) pvc didFailVerificationWithError: (NSError*) error;

@end



//Manages the embedded UIWebView that is displayed for users to authenticate to Persona
//NSNotifications are used to inform the PersonaViewController when controls -external- to the UIWebView are used
// to cancel the personaView display, or to logout.  This prevents explicit wiring from the delegate to the view,
// and is also used by other portions of the native UI to reset to initial state, ie: after logout.
//
//The notifications used are at the top of this file

@interface PersonaViewController : UIViewController <UIWebViewDelegate>
{
}

- (id)initWithOrigin:(NSString*)origin;
- (void)verifyAssertion:(NSString*)assertion againstServer:(NSURL*)server completionHandler:(URLConnectionHandler)completion;
- (void)logout:(NSNotification *)notification;

@property (nonatomic,strong) UIWebView* webView;
@property (nonatomic,strong) id<PersonaViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString* origin;
@property (nonatomic,strong) NSString* assertion;

@end
