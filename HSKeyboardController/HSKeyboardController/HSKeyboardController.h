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

extern NSString * const HSKeyboardControllerNotificationKeyPress;

/**
 
 The `HSKeyboardController` is a class you can use to control aspects of your iOS App when running in the simulator.  It is basically a stripped-down version of DCIntrospect, based on the same code.
 
 You use it just like DCIntrospect:  in your AppDelegate you call:
 
 [[HSKeyboardController sharedController] start];
 
 after that you can toggle the controller on/off by hitting the spacebar.
 
 You can in use the keys a-z and A-Z, as well as the numeric keypad's 0-9 keys, and the arrow keys (in combination with shift or alt)
 
 HOW TO USE:
 
 register for key presses you are interested using NSNotificationCenter, and register a HSKeyEvent object
 
 
 
 */


@interface HSKeyboardController : NSObject<UITextViewDelegate>

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL keyboardBindingsOn;									// default: YES
@property (nonatomic, retain) UITextView *inputTextView;
@property (nonatomic) BOOL handleArrowKeys;

+ (HSKeyboardController*)sharedController;

- (void)start;

@end


@interface HSKeyEvent : NSObject

+ (HSKeyEvent*)keyEventForKey:(NSString*)key;
+ (HSKeyEvent*)keyEventForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier;  // UIKey

@end
