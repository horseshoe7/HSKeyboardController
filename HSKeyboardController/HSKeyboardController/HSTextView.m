//
//  HSTextView.m
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "HSTextView.h"
#import "HSKeyboardControllerSettings.h"

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
