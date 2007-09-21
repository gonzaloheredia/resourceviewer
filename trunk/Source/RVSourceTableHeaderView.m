//
//  RVSourceTableHeaderView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVSourceTableHeaderView.h"

static int headerInset = 10;

@implementation RVSourceTableHeaderView

-(BOOL)isOpaque
{
	return NO;
}
- (NSRect)headerRectOfColumn:(int)index {
    NSRect rect = [super headerRectOfColumn:index];

    return NSZeroRect;
}

- (NSRect)_headerCellRectOfColumn:(int)index {
   NSZeroRect;
}

- (void)drawRect:(NSRect)r
{
	NSTableColumn *column = [[_tableView tableColumns] objectAtIndex:0];
    NSCell *headerCell = [column headerCell];
	
	[[NSColor colorWithCalibratedRed:214.0/255.0 green:221.0/255.0 blue:229.0/255.0 alpha:1.0] set];
	
	NSRectFill([self bounds]);


	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowBlurRadius:1.0];
	[textShadow setShadowOffset:NSMakeSize(0,-1)];
	[textShadow setShadowColor:[NSColor whiteColor]];
	
	NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont boldSystemFontOfSize:11.0],NSFontAttributeName,
		[NSColor colorWithCalibratedRed:18.0/255.0 green:32.0/255.0 blue:44.0/255.0 alpha:1.0] , NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
		
	NSRect stringRect = [self bounds];
	stringRect.origin.x += headerInset;
	stringRect.size.width -= headerInset;

	[[[headerCell stringValue] uppercaseString] drawInRect:stringRect withAttributes:titleAttributes];
	
}

@end
