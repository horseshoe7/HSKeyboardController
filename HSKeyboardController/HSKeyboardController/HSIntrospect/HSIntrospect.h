//
//  HSIIntrospect.h
//
//  Created by Domestic Cat on 29/04/11.
//  Modified by Stephen O'Connor 14/10/2014


#define kHSIIntrospectAnimationDuration 0.08

#import <objc/runtime.h>
#include "TargetConditionals.h"

#import "HSKeyboardControllerSettings.h"
#import "HSIFrameView.h"
#import "HSIStatusBarOverlay.h"

#ifdef DEBUG

@interface UIView (debug)

- (NSString *)recursiveDescription;

@end

#endif


extern NSString * const HSIntrospectNotificationKeyControlDidStart;
extern NSString * const HSIntrospectNotificationKeyControlDidEnd;
extern NSString * const HSIntrospectNotificationKeyPress;  // you can register for A-Z, a-z (except i,o,p,k,l), numerical keypad numbers, and arrow keys with modifiers (option and shift)
extern NSString * const HSIntrospectUserInfoSelectedView;


@interface HSIntrospect : NSObject <HSIFrameViewDelegate, UITextViewDelegate, UIWebViewDelegate>
{
}

@property (nonatomic) BOOL keyboardBindingsOn;									// default: YES
@property (nonatomic) BOOL showStatusBarOverlay;								// default: YES
@property (nonatomic, retain) UIGestureRecognizer *invokeGestureRecognizer;		// default: nil

@property (nonatomic) BOOL on;
@property (nonatomic) BOOL handleArrowKeys;
@property (nonatomic) BOOL viewOutlines;

@property (nonatomic, retain) HSIFrameView *frameView;
@property (nonatomic, retain) UITextView *inputTextView;
@property (nonatomic, retain) HSIStatusBarOverlay *statusBarOverlay;


@property (nonatomic, assign) UIView *currentView;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGFloat originalAlpha;
@property (nonatomic, retain) NSMutableArray *currentViewHistory;


///////////
// Setup //
///////////

+ (HSIntrospect *)sharedIntrospector;		// this returns nil when NOT in DEGBUG mode
- (void)start;								// NOTE: call setup AFTER [window makeKeyAndVisible] so statusBarOrientation is reported correctly.

////////////////////
// Custom Setters //
////////////////////

- (void)setInvokeGestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer;
- (void)setKeyboardBindingsOn:(BOOL)keyboardBindingsOn;

//////////////////
// Main Actions //
//////////////////

- (void)invokeIntrospector;					// can be called manually
- (void)touchAtPoint:(CGPoint)point;		// can be called manually
- (void)selectView:(UIView *)view;
- (void)statusBarTapped;

//////////////////////
// Keyboard Capture //
//////////////////////

- (void)textViewDidChangeSelection:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string;


////////////
// Layout //
////////////

- (void)updateFrameView;
- (void)updateStatusBar;
- (void)updateViews;
- (void)showTemporaryStringInStatusBar:(NSString *)string;

/////////////
// Actions //
/////////////



- (void)toggleOutlines;
- (void)addOutlinesToFrameViewFromSubview:(UIView *)view;
- (void)setBackgroundColor:(UIColor *)color ofNonOpaqueViewsInSubview:(UIView *)view;
- (void)callDrawRectOnViewsInSubview:(UIView *)subview;


/////////////////////////////
// (Somewhat) Experimental //
/////////////////////////////

- (NSArray *)subclassesOfClass:(Class)parentClass;


////////////////////
// Helper Methods //
////////////////////

- (UIWindow *)mainWindow;
- (NSMutableArray *)viewsAtPoint:(CGPoint)touchPoint inView:(UIView *)view;
- (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha;
- (BOOL)view:(UIView *)view containsSubview:(UIView *)subview;
- (BOOL)shouldIgnoreView:(UIView *)view;

@end
