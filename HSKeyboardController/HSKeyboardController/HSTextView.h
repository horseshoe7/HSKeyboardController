//
//  HSTextView.h
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HSTextViewDelegate <UITextViewDelegate>

- (void)invokeKeyboardController;

// compare string to know which key: with UIKeyInputUpArrow, UIKeyInputDownArrow, UIKeyInputLeftArrow, UIKeyInputRightArrow
- (void)arrowKeyPressed:(NSString*)key modifier:(UIKeyModifierFlags)modifiers;

// a-z and A-Z
- (void)alphaKeyPressed:(NSString*)key;

// 0 - 9 on numeric pad
- (void)numericPadKeyPressed:(NSInteger)numberKey;

@end


@interface HSTextView : UITextView

@property (nonatomic, weak) id<HSTextViewDelegate> keyboardInputDelegate;

@end
