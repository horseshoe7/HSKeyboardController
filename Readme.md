#About

HSKeyboardController is a stripped down version of the famous DCIntrospect, repurposed just to be able to use the keyboard input.  It has nothing to do with DCIntrospect after that and is NOT used for debugging layouts.

The primary use of HSKeyboardController is to be able to simulate and trigger events in your code.  What sorts of events is really up to your imagination.

#How to use

## Installation

Just drag the HSKeyboardController.h/.m files into your project, then import the header file where required.

## Setup
Just like in DCIntrospect, you initialize it in your AppDelegate.m ```applicationDidFinishLaunchingWithOptions:``` method:

```
#if TARGET_IPHONE_SIMULATOR
    [[HSIntrospect sharedIntrospector] start];
#endif
```

and then enable/disable it with the space bar.

## Subscribe to Key Events

The tool is useless until you set it up to listen for key events.  In your Application code, register for instances of HSKeyEvent like this:

```
__weak MyViewController *weakself = self;
id  observer = [[NSNotificationCenter defaultCenter] addObserverForName:HSIntrospectNotificationKeyPress
                                                                 object:[HSKeyEvent keyEventForKey:@"z"]
                                                                  queue:[NSOperationQueue mainQueue]
                         								     usingBlock:^(NSNotification *note) 
												{    
													  [weakself pressedSmallZ:note];
                                                }];
```
then...
```
- (void)pressedSmallZ:(NSNotification*)notification
{
       
		// do something here that your code otherwise uses an event trigger for 
		// (like simulating an event that triggers an internal notification, for example)
        // InternalDummyNotification *d = [InternalDummyNotification new];
        // d.messageText = @"Hey! Something happened!";
        // [self.myApplicationController processInternalNotification:d];
}
```

### Event Specifics

Currently I made it just so that you can listen for a-z and A-Z .e.g.

```HSKeyEvent *smallZ = [HSKeyEvent keyEventForKey:@"z"];```

and arrow keys on the numeric keypad with:

```HSKeyEvent *downArrow = [HSKeyEvent keyEventForKey:@"2" modifier:UIKeyModifierNumericPad];```

It also supports events involving the shift key and the alt key and the arrow keys.


# License

Mad props to Domestic Cat, a house full of way more talented people than me.  Thank you for giving us open source to modify as we see fit!

In turn, this is the same license for you.  Do what you want with it, just don't send your lawyers after me for anything.  This software is provided as-is, and I am not responsible for what you do with it.  I believe that's called MIT.

# Author

Stephen O'Connor enjoys writing code, got started with it a bit later in his life, as such will never be super awesome, but likes to make dents wherever he can.  He is a freelance iOS developer and can be reached at oconnor.freelance@gmail.com

