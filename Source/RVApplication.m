//
//  RVApplication.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVApplication.h"
#import <Quicktime/Quicktime.h>

@implementation RVApplication


NSArray *supportedImageResourceTypes()
{
	return [[NSArray arrayWithObjects:@"PICT", @"PNG ", @"PNGf", @"icns", @"kcns", @"CURS", @"crsr", @"BICN", @"GIFf", @"pxm#", @"ICN#", @"PICr", @"PICp", @"PICi", @"PICn", nil] retain];
}

-(NSImage *)imageForResource:(RVResource *)res
{


	SEL creator = [self thumbnailCreatorForResource:res];
	
	return [self performSelector:creator withObject:res];

}

SEL thumbnailCreatorForResource(RVResource *res)
{
	NSString *t = res.type;

	if (NSStringsAreEqual(t, @"PICT"))
		return @selector(PICTImageFromResource:);
	else if (NSStringsAreEqual(t, @"kcns"))
		return @selector(bitmapImageFromResource:);
	else if (NSStringsAreEqual(t, @"icns"))
		return @selector(bitmapImageFromResource:);
	else if (NSStringsAreEqual(t, @"PNGf"))
		return @selector(bitmapImageFromResource:);
	else if (NSStringsAreEqual(t, @"PNG "))
		return @selector(bitmapImageFromResource:);
	else if (NSStringsAreEqual(t, @"CURS"))
		return @selector(CURSImageFromResource:);
	else if (NSStringsAreEqual(t, @"crsr"))
		return @selector(crsrImageFromResource:);
	//else if (NSStringsAreEqual(t, @"cicn"))
//		return @selector(cicnImageFromResource:);
	else if (NSStringsAreEqual(t, @"BICN"))
		return @selector(PDFImageFromResource:);
	else if (NSStringsAreEqual(t, @"GIFf"))
		return @selector(bitmapImageFromResource:);
		
	else if (NSStringsAreEqual(t, @"PICr"))
		return @selector(bitmapImageFromResource:);
		else if (NSStringsAreEqual(t, @"PICp"))
		return @selector(bitmapImageFromResource:);
		else if (NSStringsAreEqual(t, @"PICi"))
		return @selector(bitmapImageFromResource:);
		else if (NSStringsAreEqual(t, @"PICn"))
		return @selector(bitmapImageFromResource:);
		
	else if (NSStringsAreEqual(t, @"pxm#"))
		return @selector(pixmapImageFromResource:);
	else if (NSStringsAreEqual(t, @"ICN#"))
		return @selector(ICNSharpImageFromResource:);


	else
		return @selector(textThumbnailFromResource:);
}

-(SEL)thumbnailCreatorForResource:(RVResource *)res
{
	return thumbnailCreatorForResource(res);
}

#pragma mark -
#pragma mark Resource Image Importers

-(NSImage *)ICNSharpImageFromResource:(RVResource *)res
{
	ResType currentResourceType = NSResTypeFromString(res.type);

	Handle theCIcon = GetIndResource(currentResourceType, [res.index intValue]);
	

IconFamilyHandle iconFamily = (IconFamilyHandle)NewHandle(0);



SetIconFamilyData(iconFamily, currentResourceType, theCIcon);


return [[IconFamily iconFamilyWithIconFamilyHandle: iconFamily] imageWithAllReps];
}

#define L NSLog

-(NSImage *)pixmapImageFromResource:(RVResource *)res
{
	ResType currentResourceType = NSResTypeFromString(res.type);
	Handle resH = GetIndResource(currentResourceType, [res.index intValue]);

	pxmRef myPxmRef = pxmCreate(*resH, GetHandleSize(resH));
	NSImage *image = [NSImage imageFrompxmArrayData:[NSData dataWithBytesNoCopy:myPxmRef length:GetHandleSize(resH) freeWhenDone:NO]];

	pxmDispose(myPxmRef);
	ReleaseResource(resH);

	return [image retain];
}

-(NSImage *)PDFImageFromResource:(RVResource *)res
{
	NSPDFImageRep *rep = [[NSPDFImageRep alloc] initWithData:res.data];

	NSImage *pImage = [[NSImage alloc] initWithSize:[rep size]];
	[pImage addRepresentation:rep]; 
	[rep release];
	
	[pImage setFlipped:YES];
	
	return [pImage retain];

}

-(NSImage *)cicnImageFromResource:(RVResource *)res
{
	return nil;
}

-(NSImage *)crsrImageFromResource:(RVResource *)res
{
	ResType currentResourceType = NSResTypeFromString(res.type);
	Handle cursHand = GetIndResource(currentResourceType, [res.index intValue]);
	
	NSImage *image;
	CCrsrPtr carbCursor;
	
	if (cursHand) {
		carbCursor = *((CCrsrHandle)cursHand);
		
		if (carbCursor) {
			image = [[[NSImage alloc] initWithSize: NSMakeSize(16.0f, 16.0f)] autorelease];

			/* 1-bit version */
			[image addRepresentation: [self imageRepWithBits16Data: carbCursor->crsr1Data andMask: carbCursor->crsrMask]];		
			
			return [image retain];
		}
	}
	
	return nil;
}

-(NSImage *)CURSImageFromResource:(RVResource *)res
{
	ResType currentResourceType = NSResTypeFromString(res.type);
	Handle cursHand = GetIndResource(currentResourceType, [res.index intValue]);

	NSImage *image;
	CursPtr carbCursor;

	if (cursHand) {
		carbCursor = *((CursHandle)cursHand);
		
		image = [[[NSImage alloc] initWithSize: NSMakeSize(16.0f, 16.0f)] autorelease];
		[image addRepresentation: [self imageRepWithBits16Data: carbCursor->data andMask: carbCursor->mask]];
		
		return [image retain];

	}
	
	return nil;

}

-(NSImage *)textThumbnailFromResource:(RVResource *)res
{
	NSData *data = res.data;
	
	NSImage *thumb = [[NSImage alloc] initWithSize:NSMakeSize(256, 256)];
	NSTextView *thumbContainer = [NSTextView new];
	[thumb setFlipped:YES];
	
	NSImage *badge = [NSImage imageNamed:@"DATA Badge"];
	[badge setFlipped:YES];
	
	[thumbContainer setFrame:NSMakeRect(0,0,256,256)];
	
	NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding] retain];
	[thumbContainer setString:dataStr];
	[thumbContainer setFont:[NSFont fontWithName:@"Monaco" size:20]];
	
	[thumb lockFocus];
	[thumbContainer drawRect:NSMakeRect(0,0,256,256)];
	[badge drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[thumb unlockFocus];
	
	
	

	return [thumb retain];

}

-(NSImage *)bitmapImageFromResource:(RVResource *)res
{
	NSData *d = res.data;

	NSBitmapImageRep *currentRep = [[NSBitmapImageRep alloc] initWithData:d];
							
	NSImage *pImage = [[NSImage alloc] initWithSize:[currentRep size]];
	[pImage addRepresentation:currentRep]; 
	[currentRep release];
	
	return [pImage retain];
}

-(NSImage *)PICTImageFromResource:(RVResource *)res
{
	NSData *d = res.data;

	NSPICTImageRep *currentRep = [[NSPICTImageRep alloc] initWithData:d];
							
	NSImage *pImage = [[NSImage alloc] initWithSize:[currentRep size]];
	[pImage addRepresentation:currentRep];
	[currentRep release];	
	
	return [pImage retain];
}

#pragma mark -



NSRect hackBlendRects(NSRect start, NSRect end,float b){
	
	return NSMakeRect(  round(NSMinX(start)*(1-b) + NSMinX(end)*b),
						round(NSMinY(start)*(1-b) + NSMinY(end)*b),
						round(NSWidth(start)*(1-b) + NSWidth(end)*b),
						round(NSHeight(start)*(1-b) + NSHeight(end)*b));
}

#pragma mark -
#pragma mark Resource String Methods


NSString *NSStringFromResType(ResType type) {
	char buff[5];
	
	/* this is endian-safe, works on Intel and PPC */
	
	buff[0] = (type & 0xFF000000) >> 24;
	buff[1] = (type & 0x00FF0000) >> 16;
	buff[2] = (type & 0x0000FF00) >> 8;
	buff[3] = (type & 0x000000FF) >> 0;
	buff[4] = 0;
	
	return [(NSString *)CFStringCreateWithCString(NULL, buff, kCFStringEncodingMacRoman) autorelease];
}

ResType NSResTypeFromString(NSString *string) {
	char buff[5];
	
	/* this is endian-safe, works on Intel and PPC */
	
	if (string && CFStringGetCString((CFStringRef)string, buff, sizeof(buff), kCFStringEncodingMacRoman)) {
		return (buff[0] << 24) | (buff[1] << 16) | (buff[2] << 8) | (buff[3] << 0);
	} else {
		return kUnknownType;
	}
}

NSString *NSPascalStringGetString(ConstStringPtr aString) {
	id result;
	
	if (aString) {
		/* create the string */
		result = (id)CFStringCreateWithPascalString(NULL, (ConstStr255Param)aString, kCFStringEncodingMacRoman);
		return [result autorelease];
	} else {
		return nil;
	}
}

unsigned int NSUnsignedIntFromSize(Size sz) {
	unsigned int len;
	
	if (sz > UINT_MAX)
		len = UINT_MAX;
	else if (sz < 0)
		len = 0;
	else
		len = (unsigned int)sz;
	
	return len;
}

#pragma mark - 

- (NSImageRep *)imageRepWithBits16Data: (const Bits16)data andMask: (const Bits16)mask {
	NSBitmapImageRep *result;
	unsigned char *bmData;
	int x;
	int y;
	uint16_t row;
	uint16_t rowMask;

	if (data && mask) {
		result = [[NSBitmapImageRep alloc]
			initWithBitmapDataPlanes:	NULL
			pixelsWide:					16
			pixelsHigh:					16
			bitsPerSample:				8
			samplesPerPixel:			2
			hasAlpha:					YES
			isPlanar:					NO
			colorSpaceName:				NSDeviceBlackColorSpace
			bytesPerRow:				32
			bitsPerPixel:				16];
		bmData = [result bitmapData];
		for (y = 0; y < 16; y++) {
			row = CFSwapInt16BigToHost(data[y]);
			rowMask = CFSwapInt16BigToHost(mask[y]);
			for (x = 0; x < 16; x++) {
				bmData[0] = (row & (1 << (15 - x))) ? 0x00 : 0xFF;	// Fixed
				bmData[1] = (rowMask & (1 << (15 - x))) ? 0xFF : 0x00;
				bmData += 2;
			}
		}
		return [result autorelease];
	}
	
	return nil;
}

@end
