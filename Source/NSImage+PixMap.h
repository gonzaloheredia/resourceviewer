//
//  NSImage+PixMap.h
//  ResViewer
//
//  Created by Steven Troughton-Smith on 04/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#include <Carbon/Carbon.h>
#import "pxmLib.h"
#import <Cocoa/Cocoa.h>

@interface NSImage (PixMap)

+ (NSImage *)imageFrompxmArrayWithResourceID:(short)resID inResourceFileAtPath:(NSString *)path forkName:(struct HFSUniStr255 *)forkName;
+ (NSImage *)imageFrompxmArrayWithResourceID:(short)resID inResourceFileAtPath:(NSString *)path;
+ (NSImage *)imageFrompxmArrayInSearchPathWithResourceID:(short)resID;
+ (NSImage *)imageFromSystemwidepxmArrayWithResourceID:(short)resID;

+ (NSImage *)imageFrompxmArrayData:(NSData *)data;

@end
