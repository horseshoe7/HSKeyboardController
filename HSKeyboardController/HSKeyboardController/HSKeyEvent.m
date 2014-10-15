//
//  HSKeyEvent.m
//  HSKeyboardController
//
//  Created by Stephen O'Connor on 15/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "HSKeyEvent.h"

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

