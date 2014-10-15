//
//  HSKeyboardControllerSettings.h
//  DebugKeys
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

// Global //
#define kHSKeyboardControllerInvoke							@" "		// starts introspector

#define kHSIntrospectKeysMoveUpInViewHierarchy             @"o"
#define kHSIntrospectKeysMoveBackInViewHierarchy           @"p"
#define kHSIntrospectKeysMoveDownToFirstSubview            @"i"
#define kHSIntrospectKeysMoveToNextSiblingView             @"l"
#define kHSIntrospectKeysMoveToPrevSiblingView             @"k"


//////////////
// Settings //
//////////////

#define kHSIntrospectFlashOnRedrawColor [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.4f]			// UIColor
#define kHSIntrospectFlashOnRedrawFlashLength 0.03f													// NSTimeInterval
#define kHSIntrospectOpaqueColor [UIColor redColor]													// UIColor
#define kHSIntrospectAmbiguousColor [UIColor yellowColor]											// UIColor
#define kHSIntrospectTemporaryDisableDuration 10.