//
//  HSKeyboardController.m
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "HSKeyboardController.h"


NSString * const HSKeyboardControllerNotificationKeyControlDidStart = @"HSKeyboardControllerNotificationKeyControlDidStart";
NSString * const HSKeyboardControllerNotificationKeyControlDidEnd = @"HSKeyboardControllerNotificationKeyControlDidEnd";

NSString * const HSKeyboardControllerNotificationKeyPress = @"HSKeyboardControllerNotificationKeyPress";

#pragma mark -
#pragma mark - HSKeyEvent

@interface HSKeyEvent()

@property (nonatomic, strong) UIKeyCommand *command;

@end

static NSCache *kCommandCache = nil;


@implementation HSKeyEvent

+ (void)initialize
{
    if (self == [HSKeyEvent class]) {
        kCommandCache = [[NSCache alloc] init];
    }
}

+ (HSKeyEvent*)cachedEventForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier
{
    HSKeyEvent *event = nil;
    if (modifier == 0 && [key isEqualToString:[key uppercaseString]]) {
        key = [key lowercaseString];
        modifier = UIKeyModifierShift;
    }
    NSString *cacheKey = [self cacheNameForKey:key modifier:modifier];
    event = [kCommandCache objectForKey: cacheKey];
    
    
    return event;
    
}

+ (NSString*)cacheNameForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%ul", key, (unsigned int)modifier];
    return cacheKey;
}

+ (HSKeyEvent*)keyEventForKey:(NSString*)key
{
    return [HSKeyEvent keyEventForKey:key modifier:0];
}

+ (HSKeyEvent*)keyEventForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier
{
    HSKeyEvent *event = [self cachedEventForKey:key modifier:modifier];
    
    if (event) {
        return event;
    }
    
    if (!event) {
        event = [[self alloc] init];
        
    }
    
    UIKeyCommand *keycommand;
    
    if (modifier != 0) {
        // then we assume the coder knows what he's doing
        keycommand = [UIKeyCommand keyCommandWithInput:key modifierFlags:modifier action:NULL];
    }
    else if ([key isEqualToString:[key uppercaseString]]) {
        // then we're dealing with an uppercase letter
        key = [key lowercaseString];
        modifier = UIKeyModifierShift;
    }
    
    keycommand = [UIKeyCommand keyCommandWithInput:key modifierFlags:modifier action:NULL];
    
    event.command = keycommand;
    
    NSString *cacheKey = [self cacheNameForKey:key modifier:modifier];
    [kCommandCache setObject:event forKey:cacheKey];
    
    return event;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    else if ([object isKindOfClass:[HSKeyEvent class]])
    {
        return [self isEqualToKeyEvent:(HSKeyEvent *)object];
    }
    return NO;
}

- (BOOL)isEqualToKeyEvent:(HSKeyEvent*)keyEvent
{
    if ([self.command.input isEqualToString:keyEvent.command.input] &&
        (self.command.modifierFlags == keyEvent.command.modifierFlags)) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.command.hash;
}

@end

#pragma mark -
#pragma mark - HSTextView


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

@implementation HSTextView


- (NSArray *)keyCommands {
    return @[[UIKeyCommand keyCommandWithInput:kHSKeyboardControllerInvoke modifierFlags:0 action:@selector(invoke)],
             /* ARROW KEYS */
             [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:UIKeyModifierShift action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:UIKeyModifierAlternate action:@selector(arrowKey:)],
             
             [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:UIKeyModifierShift action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:UIKeyModifierAlternate action:@selector(arrowKey:)],
             
             [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:0 action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:UIKeyModifierShift action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:UIKeyModifierAlternate action:@selector(arrowKey:)],
             
             [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:0 action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:UIKeyModifierShift action:@selector(arrowKey:)],
             [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:UIKeyModifierAlternate action:@selector(arrowKey:)],
             
             /* ALPHA Keys */
             /* lowercase */
             [UIKeyCommand keyCommandWithInput:@"q" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"w" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"e" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"r" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"t" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"y" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"u" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"i" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"o" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"p" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"a" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"s" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"d" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"f" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"g" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"h" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"j" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"k" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"l" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"z" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"x" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"c" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"v" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"b" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"n" modifierFlags:0 action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"m" modifierFlags:0 action:@selector(alphaKey:)],
             
             /* uppercase */
             [UIKeyCommand keyCommandWithInput:@"q" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"w" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"e" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"r" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"t" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"y" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"u" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"i" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"o" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"p" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"a" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"s" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"d" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"f" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"g" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"h" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"j" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"k" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"l" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"z" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"x" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"c" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"v" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"b" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"n" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             [UIKeyCommand keyCommandWithInput:@"m" modifierFlags:UIKeyModifierShift action:@selector(alphaKey:)],
             
             /* Numeric Pad keys */
             [UIKeyCommand keyCommandWithInput:@"0" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"1" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"2" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"3" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"4" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"5" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"6" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"7" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"8" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)],
             [UIKeyCommand keyCommandWithInput:@"9" modifierFlags:UIKeyModifierNumericPad action:@selector(numericKey:)]
             
             ];
    
}

- (void)invoke
{
    [self.keyboardInputDelegate invokeKeyboardController];
}

- (void)arrowKey:(UIKeyCommand*)sender {
    
    
    switch (sender.modifierFlags) {
        case UIKeyModifierShift:
            [self.keyboardInputDelegate arrowKeyPressed:sender.input modifier:UIKeyModifierShift];
            break;
        case UIKeyModifierAlternate:
            [self.keyboardInputDelegate arrowKeyPressed:sender.input modifier:UIKeyModifierAlternate];
            break;
        default:
            [self.keyboardInputDelegate arrowKeyPressed:sender.input modifier:0];
            break;
    }
}

- (void)alphaKey:(UIKeyCommand*)sender
{
    switch (sender.modifierFlags) {
        case UIKeyModifierShift:
            [self.keyboardInputDelegate alphaKeyPressed:[sender.input uppercaseString]];
            break;
        default:
            [self.keyboardInputDelegate alphaKeyPressed:sender.input];
            break;
    }
    
    
}

- (void)numericKey:(UIKeyCommand*)sender
{
    [self.keyboardInputDelegate numericPadKeyPressed:[sender.input integerValue]];
}

@end


#pragma mark -
#pragma mark - HSKeyboardController


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
