//
//  RVAnimatingTabView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVAnimatingTabView.h"

enum
{
	RVAnimatingToLeft = 1,
	RVAnimatingToRight = 2

};

@implementation RVAnimatingTabView

- (void)_switchTabViewItem:(NSTabViewItem *)oldTabViewItem oldView:(NSView *)currentView
           withTabViewItem:(NSTabViewItem *)newTabViewItem newView:(NSView *)arrivingView
     initialFirstResponder:(NSView *)initialFirstResponder lastKeyView:(NSView *)lastKeyView
{

	if ([self numberOfTabViewItems] < 2)
	{
		[super _switchTabViewItem:oldTabViewItem oldView:currentView 
				withTabViewItem:newTabViewItem newView:arrivingView 
				initialFirstResponder:initialFirstResponder lastKeyView:lastKeyView];
		return;
	}
	
	int currentIndex = [self indexOfTabViewItem:oldTabViewItem];
	int arrivingIndex = [self indexOfTabViewItem:newTabViewItem];
	int direction = 0;
	
	if (currentIndex < arrivingIndex)	// Animating to left
	direction = RVAnimatingToLeft;
	else								// Animating to right
	direction = RVAnimatingToRight;

	NSViewAnimation *theAnim;

    NSMutableDictionary* currentViewDict;
    NSMutableDictionary* arrivingViewDict;
	
 
    {
        currentViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
 
        [currentViewDict setObject:currentView forKey:NSViewAnimationTargetKey];
 
        [currentViewDict setObject:[NSValue valueWithRect:[currentView frame]]
                 forKey:NSViewAnimationStartFrameKey];
 
		switch (direction)
		{
			case RVAnimatingToLeft:
			{
				NSRect orderedOutFrame;
				orderedOutFrame = [self bounds];
				orderedOutFrame.origin.x = -[currentView frame].size.width;

				[currentViewDict setObject:[NSValue valueWithRect:orderedOutFrame]
						 forKey:NSViewAnimationEndFrameKey];
						 
				break;
			}
			case RVAnimatingToRight:
			{			
				NSRect orderedOutFrame;
				orderedOutFrame = [self bounds];
				orderedOutFrame.origin.x = [currentView frame].size.width;

				[currentViewDict setObject:[NSValue valueWithRect:orderedOutFrame]
						 forKey:NSViewAnimationEndFrameKey];	
				
				break;
			}
		}
    }
 
    {
		NSRect arrivingViewFrame;

		arrivingViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
        arrivingViewFrame = [self bounds];
		
		switch (direction)
		{
			case RVAnimatingToLeft:
			{
				arrivingViewFrame.origin.x = [self bounds].size.width;
				break;
			}
			case RVAnimatingToRight:
			{	
				arrivingViewFrame.origin.x = -[self bounds].size.width;
				break;
			}
		}

        [arrivingViewDict setObject:arrivingView forKey:NSViewAnimationTargetKey];
 
        [arrivingViewDict setObject:[NSValue valueWithRect:arrivingViewFrame]
                 forKey:NSViewAnimationStartFrameKey];

        [arrivingViewDict setObject:[NSValue valueWithRect:[self bounds]]
                 forKey:NSViewAnimationEndFrameKey];
	}

	theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
                arrayWithObjects:currentViewDict, arrivingViewDict, nil]];
 
    // Set some additional attributes for the animation.
    [theAnim setDuration:0.3];    
    [theAnim setAnimationCurve:NSAnimationEaseInOut];
	[theAnim setFrameRate:0.0];
	[theAnim setDelegate:self];
    // Run the animation.
    [theAnim startAnimation];

	[super _switchTabViewItem:oldTabViewItem oldView:currentView 
				withTabViewItem:newTabViewItem newView:arrivingView 
				initialFirstResponder:initialFirstResponder lastKeyView:lastKeyView];
	
	[self addSubview:currentView];
}

- (void)animationDidEnd:(NSViewAnimation *)animation
{
	[[[[animation viewAnimations] objectAtIndex:0] objectForKey:NSViewAnimationTargetKey] removeFromSuperview];
}


@end
