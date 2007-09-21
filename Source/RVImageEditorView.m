//
//  RVImageEditorView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVImageEditorView.h"

/*
@interface IKImageView (Private)
-(void)centerImage;

@end
*/

@implementation RVImageEditorView


-(void)awakeFromNib
{
	//[self setCurrentToolMode: IKToolModeMove];
   // [self setDelegate: self];
	//[self setDoubleClickOpensImageEditPanel:NO];
	
//	[self setHasHorizontalScroller:YES];
//	[self setHasVerticalScroller:YES];
	/*	[self setEditable:YES];
	*/
	
//	[self setImageFrameStyle:1];
	
	NSNotificationCenter *nc =[NSNotificationCenter defaultCenter];
		
	[nc addObserver:self
			   selector:@selector(recenterImage)
				   name:NSViewFrameDidChangeNotification
				 object:self];

	
}

-(void)recenterImage
{
	//[[NSAnimationContext currentContext] setDuration:0.0];
	[self centerImage];

}



-(void)setZoomFactor:(float)factor
{
	[super setZoomFactor:factor];
	
	NSLog(@"shoud scale to %@", [[NSNumber numberWithFloat:factor] stringValue]);
	[self drawRect:[self bounds]];
}



@end
