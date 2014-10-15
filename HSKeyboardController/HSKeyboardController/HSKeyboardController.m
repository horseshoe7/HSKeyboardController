//
//  HSKeyboardController.m
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "HSKeyboardController.h"
#import "HSKeyboardControllerSettings.h"
#import "HSTextView.h"
#import "HSKeyEvent.h"

NSString * const HSKeyboardControllerNotificationKeyControlDidStart = @"HSKeyboardControllerNotificationKeyControlDidStart";
NSString * const HSKeyboardControllerNotificationKeyControlDidEnd = @"HSKeyboardControllerNotificationKeyControlDidEnd";

NSString * const HSKeyboardControllerNotificationKeyPress = @"HSKeyboardControllerNotificationKeyPress";






@interface HSKeyboardController()<HSTextViewDelegate>

@property(nonatomic, assign, getter=isKeyboardVisible) BOOL keyboardVisible;

@end

@implementation HSKeyboardController

+ (HSKeyboardController*)sharedController
{
    static HSKeyboardController *sharedInstance = nil;
#if TARGET_IPHONE_SIMULATOR
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.keyboardBindingsOn = YES;
        
    });
#endif
    return sharedInstance;
}

- (void)start
{
    UIWindow *mainWindow = [self mainWindow];
    if (!mainWindow)
    {
        NSLog(@"HSIIntrospect-ARC: Couldn't setup.  No main window?");
        return;
    }
 
    if (!self.inputTextView)
    {
        if (iOS7OrHigher()) {
            self.inputTextView = [[HSTextView alloc] initWithFrame:CGRectMake(0, -100, 100, 100)];
            [(HSTextView*)self.inputTextView setKeyboardInputDelegate: self];
        }
        else {
            self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, -100, 100, 100)];
            self.inputTextView.delegate = self;
        }
        self.inputTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.inputTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.inputTextView.inputView = [[UIView alloc] init];
        self.inputTextView.scrollsToTop = NO;
        [mainWindow addSubview:self.inputTextView];
    }
    
    if (self.keyboardBindingsOn)
    {
        if (![self.inputTextView becomeFirstResponder])
        {
            [self performSelector:@selector(takeFirstResponder) withObject:nil afterDelay:0.5];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.keyboardVisible = YES;
    }];
    
    // reclaim the keyboard after dismissal if it is taken
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.keyboardVisible = NO;
        
        // needs to be done after a delay or else it doesn't work for some reason.
        if (self.keyboardBindingsOn)
            [self performSelector:@selector(takeFirstResponder)
                       withObject:nil
                       afterDelay:0.1];
    }];
    
    // dirty hack for UIWebView keyboard problems
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(takeFirstResponder) object:nil];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (!self.keyboardVisible)
        {
            [self performSelector:@selector(takeFirstResponder) withObject:nil afterDelay:0.1];
        }
    }];
    
    
    
    NSLog(@"HSIIntrospect-ARC is setup. %@ to start.", [kHSKeyboardControllerInvoke isEqualToString:@" "] ? @"Push the space bar" : [NSString stringWithFormat:@"Type '%@'",  kHSKeyboardControllerInvoke]);
}

- (void)takeFirstResponder
{
    if (![self.inputTextView becomeFirstResponder])
        NSLog(@"HSIIntrospect-ARC: Couldn't reclaim keyboard input.  Is the keyboard used elsewhere?");
}

- (void)resetInputTextView
{
    self.inputTextView.text = @"\n2 4567 9\n";
    self.handleArrowKeys = NO;
    self.inputTextView.selectedRange = NSMakeRange(5, 0);
    self.handleArrowKeys = YES;
}

#pragma mark Invocation

#pragma mark Main Actions

- (void)invokeIntrospector
{
    if (!self.on)
    {
        self.on = YES;
        
        if (self.keyboardBindingsOn)
            [self.inputTextView becomeFirstResponder];
        else
            [self.inputTextView resignFirstResponder];
        
        [self resetInputTextView];
        
        NSLog(@"Keyboard Control ON");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HSKeyboardControllerNotificationKeyControlDidStart
                                                            object:nil];
    }
    else
    {
        self.on = NO;
        
        NSLog(@"Keyboard Control OFF");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HSKeyboardControllerNotificationKeyControlDidEnd
                                                            object:nil];
    }
}


#pragma mark Helper Methods

- (UIWindow *)mainWindow
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    if (windows.count == 0)
        return nil;
    
    return [windows objectAtIndex:0];
}

BOOL iOS7OrHigher() {
    NSString *osVersion = @"7.0";
    NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult compareResult =  [currOsVersion compare:osVersion options:NSNumericSearch];
    return compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
}

#pragma mark Keyboard Capture

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (!(self.on && self.handleArrowKeys))
        return;
    
    // what's this all about?  If you look at the resetInputTextView, it sets the text to arrow key values
    // this whole method is used (in a clever hacky way) to be able to allow shift and option keys
    
    
    
    NSUInteger selectionLocation = textView.selectedRange.location;
    NSUInteger selectionLength = textView.selectedRange.length;
    BOOL shiftKey = selectionLength != 0;
    BOOL optionKey = selectionLocation % 2 == 1;
    
    // look to this method in the original DCIntrospect code to know how it works
    
    if (shiftKey)
    {
        
    }
    else if (optionKey)
    {
        
    }
    else
    {
        
    }
    self.handleArrowKeys = NO; //option-down arrow will get handled twice if key handling isn't disabled immediately
    [self performSelector:@selector(resetInputTextView) withObject:nil afterDelay:0.0]; //selectedRange doesn't reset correctly on iOS 6 if this isn't performed with a delay
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    if ([string isEqualToString:kHSKeyboardControllerInvoke])
    {
        [self invokeIntrospector];
        return NO;
    }
    
    if (!self.on)
    {
        return NO;
    }
    
    return NO;
}

#pragma mark - Keyboard Delegate

- (void)invokeKeyboardController
{
    [self invokeIntrospector];
}

- (NSDictionary*)userInfo
{
    return nil;  // override this in the subclass to provide stuff like selectedView, once that feature is implemented
}

- (void)arrowKeyPressed:(NSString*)key modifier:(UIKeyModifierFlags)modifiers
{
    switch (modifiers) {
        case UIKeyModifierShift:
            NSLog(@"KBC:  Shift %@", key);
            break;
        case UIKeyModifierAlternate:
            NSLog(@"KBC:  Alt - %@", key);
            break;
        default:
            NSLog(@"KBC:  %@", key);
            break;
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:HSKeyboardControllerNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:key modifier:modifiers]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}

- (void)alphaKeyPressed:(NSString*)key
{
    NSLog(@"Pressed %@", key);
    [[NSNotificationCenter defaultCenter] postNotificationName:HSKeyboardControllerNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:key modifier:0]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}

- (void)numericPadKeyPressed:(NSInteger)numberKey
{
    NSLog(@"Pressed %i", (int)numberKey);
    [[NSNotificationCenter defaultCenter] postNotificationName:HSKeyboardControllerNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:[NSString stringWithFormat:@"%i", (int)numberKey] modifier:UIKeyModifierNumericPad]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}



@end
