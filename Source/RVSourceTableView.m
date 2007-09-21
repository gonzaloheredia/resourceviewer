//
//  RVSourceTableView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVSourceTableView.h"

@interface NSTableView (PrivateMethods)

@end

@implementation RVSourceTableView

-(void)_drawSelectionListHighlightInRect:(NSRect)highlightRect
{	
	NSImage *gradient = [NSImage imageNamed:@"Selection Gradient"];
	[gradient setFlipped:YES];
	
	NSImage *_active = [[NSImage alloc] initWithSize:NSMakeSize(1, [gradient size].height)];
	NSImage *_inactive = [[NSImage alloc] initWithSize:NSMakeSize(1, [gradient size].height)];

	[_active lockFocus];
	[gradient drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[_active unlockFocus];
	
	[_inactive lockFocus];
	[gradient drawAtPoint:NSMakePoint(-1, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[_inactive unlockFocus];

	if ([[self window] isKeyWindow])	
		[_active drawInRect:highlightRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	else
		[_inactive drawInRect:highlightRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];


}

@end
