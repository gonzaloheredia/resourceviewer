//
//  RVApplication.h
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVResource.h"
#import "pxmLib.h"
#import "NSImage+PixMap.h"
#import "IconFamily.h"

@interface RVApplication : NSApplication {

}

-(NSImage *)imageForResource:(RVResource *)res;
SEL thumbnailCreatorForResource(RVResource *res);
-(SEL)thumbnailCreatorForResource:(RVResource *)res;

-(NSImage *)CURSImageFromResource:(RVResource *)res;
-(NSImage *)textThumbnailFromResource:(RVResource *)res;
-(NSImage *)bitmapImageFromResource:(RVResource *)res;
-(NSImage *)PICTImageFromResource:(RVResource *)res;

NSArray *supportedImageResourceTypes();

NSRect hackBlendRects(NSRect start, NSRect end,float b);
NSString *NSStringFromResType(ResType type);
ResType NSResTypeFromString(NSString *string);
NSString *NSPascalStringGetString(ConstStringPtr aString);
unsigned int NSUnsignedIntFromSize(Size sz);

@end
