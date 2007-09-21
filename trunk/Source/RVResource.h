//
//  RVResource.h
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RVResource : NSObject {

	NSString *_type;
	NSString *_name;
	ResID _identifier;
	NSString *_index;
	NSData *_data;
	Handle _handle;
}

@property NSString *type;
@property NSString *name;
@property ResID identifier;
@property NSString *index;
@property NSData *data;
@property Handle handle;


@end
