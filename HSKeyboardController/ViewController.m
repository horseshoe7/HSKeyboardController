//
//  ViewController.m
//  HSKeyboardController
//
//  Created by Stephen O'Connor on 13/10/14.
//  Copyright (c) 2014 Stephen O'Connor Games. All rights reserved.
//

#import "ViewController.h"
#import "HSKeyboardController.h"


@interface ViewController ()
{
    id _keyObserver;
    int _counter;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak ViewController *weakself = self;
    _keyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:HSKeyboardControllerNotificationKeyPress
                                                      object:[HSKeyEvent keyEventForKey:@"z"]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakself pressedSmallZ:note];
                                                  }];
}

- (void)dealloc
{
    if (_keyObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_keyObserver];
    }
}

- (void)pressedSmallZ:(NSNotification*)notification
{
    UILabel *labelToAlter = (UILabel*)[self.view viewWithTag:_counter % 3 + 1];
    
    labelToAlter.text = [NSString stringWithFormat:@"Pressed z, %i times", _counter + 1];
    
    _counter++;
    
}



@end
