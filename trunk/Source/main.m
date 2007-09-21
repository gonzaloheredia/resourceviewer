//
//  main.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 02/05/2007.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@class RVScroller, _NSBrowserScrollView, RVBrowserScrollView, RVScrollView;


int main(int argc, char *argv[])
{
/*	[RVBrowserScrollView poseAsClass:[_NSBrowserScrollView class]];
	[RVScrollView poseAsClass:[NSScrollView class]];

	[RVScroller poseAsClass:[NSScroller class]];
*/
    return NSApplicationMain(argc,  (const char **) argv);
}

@implementation NSImage (HACK)

- (void)setObject:(id)anObject forKey:(id)aKey
{
}

-(id)objectForKey:(id)aKey
{
	return nil;
}
@end