//
//  RVSourceTypeCell.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVSourceTypeCell.h"

static int leftInset = 0;
static int imagePadding = 5;
static int headerInset = 10;

@implementation RVSourceTypeCell

-(void)setIsCategory:(BOOL)b
{
	isCategory = b;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];

}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (isCategory)
		[self drawCategoryInteriorWithFrame:cellFrame inView:controlView];
	else
		[self drawStandardInteriorWithFrame:cellFrame inView:controlView];
}


- (void)drawCategoryInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowBlurRadius:1.0];
	[textShadow setShadowOffset:NSMakeSize(0,-1)];
	[textShadow setShadowColor:[NSColor whiteColor]];
	
	NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSFont boldSystemFontOfSize:11.0],NSFontAttributeName,
		[NSColor colorWithCalibratedRed:18.0/255.0 green:32.0/255.0 blue:44.0/255.0 alpha:1.0] , NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
		
	if ([self isHighlighted] ){
		[titleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
			
	NSRect stringRect = cellFrame;
	stringRect.origin.x += headerInset;
	stringRect.size.width -= headerInset;

	NSSize stringSize = [[[self stringValue] uppercaseString] sizeWithAttributes:titleAttributes];

	[[[self stringValue] uppercaseString] drawInRect:NSMakeRect(stringRect.origin.x, stringRect.origin.y+(stringRect.size.height/2)-(stringSize.height/2), stringRect.size.width, stringRect.size.height) withAttributes:titleAttributes];

}

- (void)drawStandardInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.origin.x += leftInset;

	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	if ([self isHighlighted] ){
		[attrs setValue:[NSColor whiteColor] forKey:@"NSColor"];
	}
	else
	{
		[attrs setValue:[NSColor blackColor] forKey:@"NSColor"];
	}	
	
	
	NSRect imageRect;
	
	imageRect.origin = cellFrame.origin;
	imageRect.size.width = imageRect.size.height = 16;
	
	imageRect.origin.x += imagePadding;	
	
	imageRect.origin.y += (cellFrame.size.height/2)-(imageRect.size.height/2);
	
	NSImage *_cellImage = [self image];
	[_cellImage setFlipped:YES];
	[_cellImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
		
	NSRect stringRect = cellFrame;
	stringRect.origin.x = imageRect.origin.x+imageRect.size.width+imagePadding;
	
	NSSize stringSize = [[[self stringValue] uppercaseString] sizeWithAttributes:attrs];


	[[self stringValue] drawInRect:NSMakeRect(stringRect.origin.x, stringRect.origin.y+(stringRect.size.height/2)-(stringSize.height/2), stringRect.size.width, stringRect.size.height) withAttributes:attrs];
	
}

@end
