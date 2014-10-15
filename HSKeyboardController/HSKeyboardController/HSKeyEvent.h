//
//  HSKeyEvent.h
//  HSKeyboardController
//
//  Created by Stephen O'Connor on 15/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HSKeyEvent : NSObject

+ (HSKeyEvent*)keyEventForKey:(NSString*)key;
+ (HSKeyEvent*)keyEventForKey:(NSString*)key modifier:(UIKeyModifierFlags)modifier;  // UIKey

@end
