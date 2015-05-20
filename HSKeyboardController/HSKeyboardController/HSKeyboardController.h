//
//  HSKeyboardController.h
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Global //
#define kHSKeyboardControllerInvoke							@" "		// starts introspector

extern NSString * const HSKeyboardControllerNotificationKeyControlDidStart;  // i.e. you pressed the space bar
extern NSString * const HSKeyboardControllerNotificationKeyControlDidEnd;  
extern NSString * const HSKeyboardControllerNotificationKeyPress;


@class HSKeyEvent;


@interface HSKeyboardController : NSObject<UITextViewDelegate>

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL keyboardBindingsOn;									// default: YES
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic) BOOL handleArrowKeys;

+ (HSKeyboardController*)sharedController;

- (void)start;

@end



@interface HSKeyEvent : NSObject

+ (HSKeyEvent*)keyEventForKey:(NSString*)key;
+ (HSKeyEvent*)keyEventForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier;  // UIKey

@end



