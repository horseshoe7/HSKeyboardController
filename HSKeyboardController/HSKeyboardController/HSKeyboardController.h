//
//  HSKeyboardController.h
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const HSKeyboardControllerNotificationKeyControlDidStart;
extern NSString * const HSKeyboardControllerNotificationKeyControlDidEnd;

/**
 
 The `HSKeyboardController` is a class you can use to control aspects of your iOS App when running in the simulator.  It is basically a stripped-down version of DCIntrospect, based on the same code.
 
 You use it just like DCIntrospect:  in your AppDelegate you call:
 
 [[HSKeyboardController sharedController] start];
 
 after that you can toggle the controller on/off by hitting the spacebar.
 
 You can in use the keys a-z and A-Z, as well as the numeric keypad's 0-9 keys, and the arrow keys (in combination with shift or alt)
 
 */

@interface HSKeyboardController : NSObject<UITextViewDelegate>

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL keyboardBindingsOn;									// default: YES
@property (nonatomic, retain) UITextView *inputTextView;
@property (nonatomic) BOOL handleArrowKeys;

+ (HSKeyboardController*)sharedController;

- (void)start;

// wrapper for the method below
- (void)mapKey:(NSString*)key target:(id)target action:(SEL)action;

// re-using UIKeyCommand for input and modifier.  action is obviously nil
- (void)mapKeyCommand:(UIKeyCommand*)command target:(id)target action:(SEL)action;


@end