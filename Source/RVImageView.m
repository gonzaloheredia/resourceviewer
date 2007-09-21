//
//  RVImageView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVImageView.h"

NSRect hackBlendRects(NSRect start, NSRect end,float b);

BOOL NSStringsAreEqual(NSString *one, NSString *two)
{
	return [one isEqualToString:two] ? YES :  NO;
}

BOOL NSStringContainsString(NSString *original, NSString *test)
{
	return [[original lowercaseString] rangeOfString:[test lowercaseString]].length > 0 ? YES :  NO;
}

@implementation RVImageView

-(IBAction)filterByString:(id)sender
{
	[_filter release];
	_filter = [[sender stringValue] retain];
	
	[__filteredArray removeAllObjects];
	__filteredArray = [[NSMutableArray array] retain];
	
	int ce = 0;
	while (ce < [_images count])
	
	{
		RVResourceImage *currentEntry = [_images objectAtIndex:ce];
		NSString *name = [currentEntry imageSubtitle];
			NSString *index = [currentEntry imageTitle];

			if (NSStringContainsString(name, _filter) || NSStringContainsString(index, _filter))
				
			[__filteredArray addObject:currentEntry];	
		
		ce++;
	}
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];

}

-(void)awakeFromNib
{
	_images = [[[NSMutableArray alloc] init] retain];
	
	[self setDelegate:self];
	[self setDataSource:self];
	
	#ifdef LEOPARD
	[self setAnimates:YES];

	[self setCellsStyleMask:IKCellsStyleTitled|IKCellsStyleSubtitled|IKCellsStyleShadowed];
	[self setContentResizingMask:NSViewHeightSizable];
	
	[self setValue:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] forKey:IKImageBrowserBackgroundColorKey];
	
	[self setZoomValue:0.5];
	#endif


}

-(void)setController:(id)c
{
	_controller = [c retain];	
		
}

-(void)setSource:(id)source
{
	_source = [source retain];	
	
		
	[self loadImages];
	[self setDataSource:self];
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];
	
}

#pragma mark -
#pragma mark Loading the images

-(void)loadImages
{	
	int i = 0;
	
	[_images removeAllObjects];
	
	while (i < [_source count])
	{
	
	RVResourceImage *p;
	
	/* add a path to our temporary array */
    p = [[[RVResourceImage alloc] init] retain];
		
	[p setImage:[[RVApplication sharedApplication] imageForResource:[_source objectAtIndex:i]]];
		
	[p setTitle:[[NSNumber numberWithShort:((RVResource *)[_source objectAtIndex:i]).identifier] stringValue] ];
	[p setSubtitle:((RVResource *)[_source objectAtIndex:i]).name];
	[p release];

	[_images addObject:p];
	
		i++;
	}
	
}

#pragma mark -
#pragma mark IKImageBrowserDataSource

/* implement image-browser's datasource protocol 
 Our datasource representation is a simple mutable array
 */
- (int) numberOfItemsInImageFlow:(IKImageBrowserView *) view
{



	if ([_filter length] > 0)
		return [__filteredArray count];	
	else
		return [_images count];


}

- (int) numberOfItemsInImageBrowser:(IKImageBrowserView *) view
{



	if ([_filter length] > 0)
		return [__filteredArray count];	
	else
		return [_images count];


}

- (id)imageFlow:(id)view itemAtIndex:(int)index
{
	if ([_filter length] > 0)
		return [__filteredArray objectAtIndex:index];	
	else
		return [_images objectAtIndex:index];
}

- (id) imageBrowser:(IKImageBrowserView *) view itemAtIndex:(int) index
{
	if ([_filter length] > 0)
		return [__filteredArray objectAtIndex:index];	
	else
		return [_images objectAtIndex:index];
}

#pragma mark -

#pragma mark -

-(void) runDoubleClickAnimationFor:(NSWindow *) zoomAnimationWindow
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
		[zoomAnimationWindow makeKeyAndOrderFront:self];
		
		float fadeOut = 0.0;
		float elapsed, seconds;

		seconds = 1.0;
		
		NSRect startRect = [zoomAnimationWindow frame];
		NSRect frameRect = NSMakeRect( [zoomAnimationWindow frame].origin.x-1.5*[zoomAnimationWindow frame].size.width, [zoomAnimationWindow frame].origin.y-1.5*[zoomAnimationWindow frame].size.height, [zoomAnimationWindow frame].size.width*4, [zoomAnimationWindow frame].size.height*4);
		
		NSTimeInterval fadeStart = [NSDate timeIntervalSinceReferenceDate];
		for(elapsed=0.0; elapsed<1.0; elapsed = (([NSDate timeIntervalSinceReferenceDate] - fadeStart)/seconds)){
			float fadeIn=[zoomAnimationWindow alphaValue];
			float distance=fadeOut-fadeIn;
			
			[zoomAnimationWindow setAlphaValue:fadeIn+elapsed*distance];
			[zoomAnimationWindow setFrame:hackBlendRects(startRect,frameRect,elapsed) display:YES];

			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds/300.0]];
		}
		
		[zoomAnimationWindow close];
	[pool release];

}

- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(int) index
{		
		[_controller performSelectorOnMainThread:@selector(goToEditorViewForResource:) withObject:[_source objectAtIndex:index] waitUntilDone:YES ];
}



#pragma mark -

@end

@implementation RVResourceImage


-(NSString *)_subtitle
{
	return _subtitle;
}

-(NSString *)_title
{
	return _title;
}

-(NSImage *)_image
{
	return _image;
}

- (void) dealloc
{
    [_image release];
	[_title release];
    [super dealloc];
}

- (void) setSubtitle:(NSString *) subtitle
{
        [_subtitle release];
        _subtitle = [subtitle retain];
}

- (void) setTitle:(NSString *) title
{
        [_title release];
        _title = [title retain];
}

- (void) setImage:(NSImage *) image
{
   
		[_image release];
        _image = [image retain];
    
}

/* required methods of the IKImageBrowserItem protocol */
#pragma mark -
#pragma mark item data source protocol

// Tiger ImageKit Define. 
extern NSString * const IKImageBrowserNSImageRepresentationType;			/* NSImage */


/* let the image browser knows we use a path representation */
- (NSString *)  imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (NSString *) imageSubtitle
{
	return _subtitle;
}


- (NSString *) imageTitle
{
	return _title;
}

/* give our representation to the image browser */
- (NSImage *)  imageRepresentation
{
	if (!_image)
	return nil;

	return _image;
}

/* use the absolute filepath as identifier */
- (NSString *) imageUID
{
    return [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue];
}

@end