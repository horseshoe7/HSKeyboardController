//
//  HSICrossHairView.h
//
//  Created by Domestic Cat on 3/05/11.
//  Modified by Stephen O'Connor 14/10/2014

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HSICrossHairView : UIView
{
}

@property (nonatomic, retain) UIColor *color;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)aColor;

@end
