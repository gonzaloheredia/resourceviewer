//
//  RVImageView.h
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "RVApplication.h"
#import "RVResource.h"

// Tiger

@interface IKImageBrowserView : NSView
@end

@interface IKImageView : NSView
@end

@interface RVResourceImage : NSObject{
    NSImage *_image; 
	NSString *_title;
	NSString *_subtitle;
	
}
-(NSString *)_title;
-(NSImage *)_image;
- (void) setTitle:(NSString *) title;
- (void) setSubtitle:(NSString *) subtitle;

- (void) setImage:(NSImage *) image;
@end

/*
@interface IKImageFlowView : IKImageView
@end
*/

@interface RVImageView : IKImageBrowserView {

	NSMutableArray *__filteredArray;
	NSMutableArray *_images;
	NSString *_filter;

	id _source;
	id _controller;
	
	IBOutlet id scroller;
}

-(IBAction)filterByString:(id)sender;

-(void)setSource:(id)source;
-(void)loadImages;

@end