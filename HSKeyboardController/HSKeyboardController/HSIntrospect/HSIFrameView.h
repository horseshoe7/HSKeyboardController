//
//  HSIFrameView.h
//
//  Created by Domestic Cat on 29/04/11.
//  Modified by Stephen O'Connor 14/10/2014

#import <QuartzCore/QuartzCore.h>
#import "HSICrossHairView.h"

@protocol HSIFrameViewDelegate <NSObject>

@required

- (void)touchAtPoint:(CGPoint)point;

@end

@interface HSIFrameView : UIView
{

}

@property (nonatomic, assign) id<HSIFrameViewDelegate> delegate;
@property (nonatomic) CGRect mainRect;
@property (nonatomic) CGRect superRect;
@property (nonatomic, retain) UILabel *touchPointLabel;
@property (nonatomic, retain) NSMutableArray *rectsToOutline;
@property (nonatomic, retain) HSICrossHairView *touchPointView;

///////////
// Setup //
///////////

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

////////////////////
// Custom Setters //
////////////////////

- (void)setMainRect:(CGRect)newMainRect;
- (void)setSuperRect:(CGRect)newSuperRect;

/////////////////////
// Drawing/Display //
/////////////////////

- (void)drawRect:(CGRect)rect;

////////////////////
// Touch Handling //
////////////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
