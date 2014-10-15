//
//  ViewController.m
//  HSKeyboardController
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "ViewController.h"
#import "HSIntrospect.h"
#import "HSKeyEvent.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak ViewController *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:HSIntrospectNotificationKeyPress
                                                      object:[HSKeyEvent keyEventForKey:@"z"]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakself pressedX:note];
                                                  }];
}


- (void)pressedX:(NSNotification*)notification
{
    UIView *selectedView = notification.userInfo[HSIntrospectUserInfoSelectedView];
    
    if (selectedView) {
        CGRect newFrame = selectedView.frame;
        newFrame.origin.x++;
        
        selectedView.frame = newFrame;
    }
    
}



@end
