//
//  HSIntrospect.m
//
//  Created by Domestic Cat on 29/04/11.
//  Modified by Stephen O'Connor 14/10/2014

#import "HSIntrospect.h"
#import "HSKeyboardControllerSettings.h"
#import "UIView+HSIAdditions.h"
#import <dlfcn.h>
#import "HSTextView.h"
#import "HSKeyEvent.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

BOOL HSI_iOS7OrHigher(void);
NSString* _recursiveDescription(id view, NSUInteger depth);


#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)


#if TARGET_CPU_ARM
#define DEBUGSTOP(signal) __asm__ __volatile__ ("mov r0, %0\nmov r1, %1\nmov r12, %2\nswi 128\n" : : "r"(getpid ()), "r"(signal), "r"(37) : "r12", "r0", "r1", "cc");
#define DEBUGGER do { int trapSignal = AmIBeingDebugged () ? SIGINT : SIGSTOP; DEBUGSTOP(trapSignal); if (trapSignal == SIGSTOP) { DEBUGSTOP (SIGINT); } } while (false);
#elif TARGET_CPU_ARM64 || TARGET_CPU_X86_64
#define DEBUGGER // Breaking into debugger on arm64 is not currently supported
#else
#define DEBUGGER do { int trapSignal = AmIBeingDebugged () ? SIGINT : SIGSTOP; __asm__ __volatile__ ("pushl %0\npushl %1\npush $0\nmovl %2, %%eax\nint $0x80\nadd $12, %%esp" : : "g" (trapSignal), "g" (getpid ()), "n" (37) : "eax", "cc"); } while (false);
#endif

#pragma mark - Constants

NSString * const HSIntrospectNotificationKeyControlDidStart = @"HSIntrospectNotificationKeyControlDidStart";
NSString * const HSIntrospectNotificationKeyControlDidEnd = @"HSIntrospectNotificationKeyControlDidEnd";
NSString * const HSIntrospectNotificationKeyPress = @"HSIntrospectNotificationKeyPress";
NSString * const HSIntrospectUserInfoSelectedView = @"HSIntrospectUserInfoSelectedView";



@interface HSIntrospect () <HSTextViewDelegate>

@property(nonatomic, assign, getter=isKeyboardVisible) BOOL keyboardVisible;

- (void)takeFirstResponder;

@end

@implementation HSIntrospect

    
+ (HSIntrospect *)sharedIntrospector
{
	static HSIntrospect *sharedInstance = nil;
#if TARGET_IPHONE_SIMULATOR
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[HSIntrospect alloc] init];
		sharedInstance.keyboardBindingsOn = YES;
		sharedInstance.showStatusBarOverlay = ![UIApplication sharedApplication].statusBarHidden;
	});
#endif
	return sharedInstance;
}

- (void)start
{
	UIWindow *mainWindow = [self mainWindow];
	if (!mainWindow)
	{
		NSLog(@"HSIntrospect-ARC: Couldn't setup.  No main window?");
		return;
	}
	
	if (!self.statusBarOverlay)
	{
		self.statusBarOverlay = [[HSIStatusBarOverlay alloc] init];
	}
	
	if (!self.inputTextView)
	{
        if (HSI_iOS7OrHigher()) {
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

	// listen for device orientation changes to adjust the status bar
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:UIDeviceOrientationDidChangeNotification object:nil];
	
	if (!self.currentViewHistory)
		self.currentViewHistory = [[NSMutableArray alloc] init];
	
	NSLog(@"HSIntrospect-ARC is setup. %@ to start.", [kHSKeyboardControllerInvoke isEqualToString:@" "] ? @"Push the space bar" : [NSString stringWithFormat:@"Type '%@'",  kHSKeyboardControllerInvoke]);
}

- (void)takeFirstResponder
{
	if (![self.inputTextView becomeFirstResponder])
		NSLog(@"HSIntrospect-ARC: Couldn't reclaim keyboard input.  Is the keyboard used elsewhere?");
}

- (void)resetInputTextView
{
	self.inputTextView.text = @"\n2 4567 9\n";
	self.handleArrowKeys = NO;
	self.inputTextView.selectedRange = NSMakeRange(5, 0);
	self.handleArrowKeys = YES;
}

#pragma mark Custom Setters
- (void)setInvokeGestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer
{
	UIWindow *mainWindow = [self mainWindow];
	[mainWindow removeGestureRecognizer:self.invokeGestureRecognizer];
	_invokeGestureRecognizer = newGestureRecognizer;
	[self.invokeGestureRecognizer addTarget:self action:@selector(invokeIntrospector)];
	[mainWindow addGestureRecognizer:self.invokeGestureRecognizer];
}

- (void)setKeyboardBindingsOn:(BOOL)areKeyboardBindingsOn
{
	_keyboardBindingsOn = areKeyboardBindingsOn;
	if (self.keyboardBindingsOn)
		[self.inputTextView becomeFirstResponder];
	else
		[self.inputTextView resignFirstResponder];
}

#pragma mark Main Actions

- (void)invokeIntrospector
{
	if (!self.on)
	{
        self.on = YES;
		[self updateViews];
		[self updateStatusBar];
		[self updateFrameView];
		
		if (self.keyboardBindingsOn)
			[self.inputTextView becomeFirstResponder];
		else
			[self.inputTextView resignFirstResponder];
		
		[self resetInputTextView];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:HSIntrospectNotificationKeyControlDidStart
															object:nil];
	}
	else
	{
		if (self.viewOutlines)
			[self toggleOutlines];
		
		
		self.statusBarOverlay.hidden = YES;
		self.frameView.alpha = 0;
		self.currentView = nil;
		
        self.on = NO;
        
		[[NSNotificationCenter defaultCenter] postNotificationName:HSIntrospectNotificationKeyControlDidEnd
															object:nil];
	}
}

- (void)touchAtPoint:(CGPoint)point
{
	// convert the point into the main window
	CGPoint convertedTouchPoint = [[self mainWindow] convertPoint:point fromView:self.frameView];
	
	// find all the views under that point – will be added in order on screen, ie mainWindow will be index 0, main view controller at index 1 etc, note that hidden views are ignored.
	NSMutableArray *views = [self viewsAtPoint:convertedTouchPoint inView:[self mainWindow]];
	while (views.count > 0) {
        UIView *view = views.lastObject;
        BOOL hidden = NO;
        while (view) {
            if (view.hidden || view.alpha == 0) {
                hidden = YES;
                break;
            }
            view = view.superview;
        }
        if (hidden) {
            [views removeLastObject];
        } else {
            break;
        }
	}
	if (views.count == 0)
		return;
	
	// get the topmost view and setup the UI
	[self.currentViewHistory removeAllObjects];
	UIView *newView = [views lastObject];
	[self selectView:newView];
}

- (void)selectView:(UIView *)view
{
	self.currentView = view;
	self.originalFrame = self.currentView.frame;
	self.originalAlpha = self.currentView.alpha;
	
	if (self.frameView.rectsToOutline.count > 0)
	{
		[self.frameView.rectsToOutline removeAllObjects];
		[self.frameView setNeedsDisplay];
		self.viewOutlines = NO;
	}
	
	[self updateFrameView];
	[self updateStatusBar];
	
	if (![self.currentViewHistory containsObject:self.currentView])
		[self.currentViewHistory addObject:self.currentView];
}

- (void)statusBarTapped
{

}

#pragma mark Keyboard Capture

- (void)textViewDidChangeSelection:(UITextView *)textView
{
	if (!(self.on && self.handleArrowKeys))
		return;
	
	NSUInteger selectionLocation = textView.selectedRange.location;
	NSUInteger selectionLength = textView.selectedRange.length;
	BOOL shiftKey = selectionLength != 0;
	BOOL optionKey = selectionLocation % 2 == 1;
	
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
		return NO;
	
    if ([string isEqualToString:kHSIntrospectKeysMoveUpInViewHierarchy])
    {
        [self moveUpInViewHierarchy];
        return NO;
    }
    else if ([string isEqualToString:kHSIntrospectKeysMoveBackInViewHierarchy])
    {
        [self moveBackInViewHierarchy];
        return NO;
    }
    else if ([string isEqualToString:kHSIntrospectKeysMoveDownToFirstSubview])
    {
        [self moveDownToFirstSubview];
        return NO;
    }
    else if ([string isEqualToString:kHSIntrospectKeysMoveToNextSiblingView])
    {
        [self moveToNextSiblingView];
        return NO;
    }
    else if ([string isEqualToString:kHSIntrospectKeysMoveToPrevSiblingView])
    {
        [self moveToPrevSiblingView];
        return NO;
    }
		
	
	return NO;
}



#pragma mark Layout

- (void)updateFrameView
{
	UIWindow *mainWindow = [self mainWindow];
	if (!self.frameView)
	{
		self.frameView = [[HSIFrameView alloc] initWithFrame:(CGRect){ CGPointZero, mainWindow.frame.size } delegate:self];
		[mainWindow addSubview:self.frameView];
		self.frameView.alpha = 0.0f;
		[self updateViews];
	}
	
	[mainWindow bringSubviewToFront:self.frameView];
	
	if (self.on)
	{
		if (self.currentView)
		{
			self.frameView.mainRect = [self.currentView.superview convertRect:self.currentView.frame toView:self.frameView];
			if (self.currentView.superview == mainWindow)
				self.frameView.superRect = CGRectZero;
			else if (self.currentView.superview.superview)
				self.frameView.superRect = [self.currentView.superview.superview convertRect:self.currentView.superview.frame toView:self.frameView];
			else
				self.frameView.superRect = CGRectZero;
		}
		else
		{
			self.frameView.mainRect = CGRectZero;
		}
		
		[self fadeView:self.frameView toAlpha:1.0f];
	}
	else
	{
		[self fadeView:self.frameView toAlpha:0.0f];
	}
}

- (void)updateStatusBar
{
	if (self.currentView)
	{
		NSString *nameForObject = NSStringFromClass(self.currentView.class);
		
		// remove the 'self.' if it's there to save space
		if ([nameForObject hasPrefix:@"self."])
			nameForObject = [nameForObject substringFromIndex:@"self.".length];
		
		if (self.currentView.tag != 0)
			self.statusBarOverlay.leftLabel.text = [NSString stringWithFormat:@"%@ (tag: %ld)", nameForObject, (long)self.currentView.tag];
		else
			self.statusBarOverlay.leftLabel.text = [NSString stringWithFormat:@"%@", nameForObject];
		
		self.statusBarOverlay.rightLabel.text = NSStringFromCGRect(self.currentView.frame);

		if ([self.currentView respondsToSelector:@selector(hasAmbiguousLayout)])
			if ([self.currentView hasAmbiguousLayout])
				self.statusBarOverlay.rightLabel.text = [NSString stringWithFormat:@"\ue021%@", self.statusBarOverlay.rightLabel.text];
	}
	else
	{
		self.statusBarOverlay.leftLabel.text = @"HSIntrospect-ARC";
		self.statusBarOverlay.rightLabel.text = @"See Readme for instructions";
	}
	
	if (self.showStatusBarOverlay)
		self.statusBarOverlay.hidden = NO;
	else
		self.statusBarOverlay.hidden = YES;
}

- (void)updateViews
{
	// current interface orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	
	CGFloat pi = (CGFloat)M_PI;
	if (orientation == UIDeviceOrientationPortrait)
	{
		self.frameView.transform = CGAffineTransformIdentity;
		self.frameView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
	}
	else if (orientation == UIDeviceOrientationLandscapeLeft)
	{
		self.frameView.transform = CGAffineTransformMakeRotation(pi * (90) / 180.0f);
		self.frameView.frame = CGRectMake(screenWidth - screenHeight, 0, screenHeight, screenHeight);
	}
	else if (orientation == UIDeviceOrientationLandscapeRight)
	{
		self.frameView.transform = CGAffineTransformMakeRotation(pi * (-90) / 180.0f);
		self.frameView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
	}
	else if (orientation == UIDeviceOrientationPortraitUpsideDown)
	{
		self.frameView.transform = CGAffineTransformMakeRotation(pi);
		self.frameView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
	}
	
	self.currentView = nil;
	[self updateFrameView];
}

- (void)showTemporaryStringInStatusBar:(NSString *)string
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateStatusBar) object:nil];
	
	self.statusBarOverlay.leftLabel.text = string;
	self.statusBarOverlay.rightLabel.text = nil;
	[self performSelector:@selector(updateStatusBar) withObject:nil afterDelay:0.75];
}

#pragma mark Actions


- (void)toggleOutlines
{
    if (!self.on)
		return;
	
	UIWindow *mainWindow = [self mainWindow];
	self.viewOutlines = !self.viewOutlines;
	
	if (self.viewOutlines)
		[self addOutlinesToFrameViewFromSubview:mainWindow];
	else
		[self.frameView.rectsToOutline removeAllObjects];
	
	[self.frameView setNeedsDisplay];
	
	NSString *string = [NSString stringWithFormat:@"Showing view outlines is %@", (self.viewOutlines) ? @"on" : @"off"];
	if (self.showStatusBarOverlay)
		[self showTemporaryStringInStatusBar:string];
	else
		NSLog(@"HSIntrospect-ARC: %@", string);
}

- (void)addOutlinesToFrameViewFromSubview:(UIView *)view
{
	for (UIView *subview in view.subviews)
	{
		if ([self shouldIgnoreView:subview])
			continue;
		
		CGRect rect = [subview.superview convertRect:subview.frame toView:self.frameView];
		
		NSValue *rectValue = [NSValue valueWithCGRect:rect];
		[self.frameView.rectsToOutline addObject:rectValue];
		[self addOutlinesToFrameViewFromSubview:subview];
	}
}

#pragma mark - HSTextViewDelegate

- (void)invokeKeyboardController
{
    [self invokeIntrospector];
}

- (NSDictionary*)userInfo
{
    if (self.currentView) {
        return @{HSIntrospectUserInfoSelectedView : self.currentView};
    }
    
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
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HSIntrospectNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:key modifier:modifiers]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}

- (void)alphaKeyPressed:(NSString*)key
{
    if ([key isEqualToString:kHSIntrospectKeysMoveBackInViewHierarchy]) {
        [self moveBackInViewHierarchy];
        return;
    }
    else if ([key isEqualToString:kHSIntrospectKeysMoveUpInViewHierarchy]) {
        [self moveUpInViewHierarchy];
        return;
    }
    else if ([key isEqualToString:kHSIntrospectKeysMoveDownToFirstSubview]) {
        [self moveDownToFirstSubview];
        return;
    }
    else if ([key isEqualToString:kHSIntrospectKeysMoveToNextSiblingView]) {
        [self moveToNextSiblingView];
        return;
    }
    else if ([key isEqualToString:kHSIntrospectKeysMoveToPrevSiblingView]) {
        [self moveToPrevSiblingView];
        return;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HSIntrospectNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:key modifier:0]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}

- (void)numericPadKeyPressed:(NSInteger)numberKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSIntrospectNotificationKeyPress
                                                        object:[HSKeyEvent keyEventForKey:[NSString stringWithFormat:@"%i", (int)numberKey] modifier:UIKeyModifierNumericPad]
                                                      userInfo:[self userInfo]];  // should add selected view, when feature available
}


- (void)moveUpInViewHierarchy {
    if (!self.on || !self.currentView)
        return;
    
    if (self.currentView.superview)
    {
        [self selectView:self.currentView.superview];
    }
    else
    {
        NSLog(@"HSIntrospect-ARC: At top of view hierarchy.");
    }
}

- (void)moveBackInViewHierarchy {
    if (!self.on || !self.currentView || self.currentViewHistory.count == 0)
        return;
    
    NSUInteger indexOfCurrentView = [self.currentViewHistory indexOfObject:self.currentView];
    if (indexOfCurrentView == 0)
    {
        NSLog(@"HSIntrospect-ARC: At bottom of view history.");
        return;
    }
    
    [self selectView:[self.currentViewHistory objectAtIndex:indexOfCurrentView - 1]];
}

- (void)moveDownToFirstSubview {
    if (!self.on || !self.currentView)
        return;
    
    if (self.currentView.subviews.count>0) {
        [self selectView:[self.currentView.subviews objectAtIndex:0]];
    } else{
        NSLog(@"HSIntrospect-ARC: No subviews.");
    }
}

- (void)moveToNextSiblingView {
    if (!self.on || !self.currentView)
        return;
    
    NSUInteger currentViewsIndex = [self.currentView.superview.subviews indexOfObject:self.currentView];
    
    if (currentViewsIndex==NSNotFound) {
        NSLog(@"HSIntrospect-ARC: BROKEN HIERARCHY.");
    } else if (self.currentView.superview.subviews.count>currentViewsIndex + 1) {
        [self selectView:[self.currentView.superview.subviews objectAtIndex:currentViewsIndex + 1]];
    } else{
        NSLog(@"HSIntrospect-ARC: No next sibling views.");
    }
}

- (void)moveToPrevSiblingView {
    if (!self.on || !self.currentView)
        return;
    
    NSUInteger currentViewsIndex = [self.currentView.superview.subviews indexOfObject:self.currentView];
    if (currentViewsIndex==NSNotFound) {
        NSLog(@"HSIntrospect-ARC: BROKEN HIERARCHY.");
    } else if (currentViewsIndex!=0) {
        [self selectView:[self.currentView.superview.subviews objectAtIndex:currentViewsIndex - 1]];
    } else {
        NSLog(@"HSIntrospect-ARC: No previous sibling views.");
    }
}



NSString* _recursiveDescription(id view, NSUInteger depth)
{
    NSMutableString* subviewsDescription;
    subviewsDescription = [NSMutableString string];
    for (id v in [view subviews]) {
        [subviewsDescription appendString:_recursiveDescription(v, depth+1)];
    }
    
    NSMutableString* layout;
    layout = [NSMutableString string];
    for (NSUInteger i = 0; i < depth; i++) {
        [layout appendString:@"   | "];
    }
    
    return [NSString stringWithFormat:@"%@%@\n%@", layout, [view description], subviewsDescription];
}


#pragma mark Helper Methods

- (UIWindow *)mainWindow
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	if (windows.count == 0)
		return nil;
	
	return [windows objectAtIndex:0];
}

- (NSMutableArray *)viewsAtPoint:(CGPoint)touchPoint inView:(UIView *)view
{
	NSMutableArray *views = [[NSMutableArray alloc] init];
	
	if ([view pointInside:touchPoint withEvent:nil])
	{
	   [views addObject:view];
	   
	   for (UIView *subview in view.subviews)
	   {
	       if ([self shouldIgnoreView:subview])
	           continue;
	       
	       CGPoint convertedTouchPoint = [view convertPoint:touchPoint toView:subview];
	       
	       [views addObjectsFromArray:[self viewsAtPoint:convertedTouchPoint inView:subview]];
	   }
	}
	
	return views;
}

- (void)fadeView:(UIView *)view toAlpha:(CGFloat)alpha
{
	[UIView animateWithDuration:0.1
						  delay:0.0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 view.alpha = alpha;
					 }
					 completion:nil];
}

- (BOOL)view:(UIView *)view containsSubview:(UIView *)subview
{
	for (UIView *aView in view.subviews)
	{
		if (aView == subview)
			return YES;
		
		if ([self view:aView containsSubview:subview])
			return YES;
	}
	
	return NO;
}

- (BOOL)shouldIgnoreView:(UIView *)view
{
	if (view == self.frameView || view == self.inputTextView)
		return YES;
	return NO;
}

BOOL HSI_iOS7OrHigher() {
    NSString *osVersion = @"7.0";
    NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult compareResult =  [currOsVersion compare:osVersion options:NSNumericSearch];
    return compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
}

@end
