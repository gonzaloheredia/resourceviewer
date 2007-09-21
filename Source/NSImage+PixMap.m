//
//  NSImage+PixMap.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 04/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSImage+PixMap.h"
#import "pxmLib.h"


@implementation NSImage (PixMap)

+ (NSImage *)imageFrompxmArrayData:(NSData *)data {
	const struct pxmData *pxmBytes = [data bytes];

	//We currently only know how to deal with direct (RGB/RGBA) pixels. We don't know about indexed pixels yet. That will involve adding clut-handling logic.
	//NSAssert1(pxmPixelType(pxmBytes) == pxmTypeDirect16 || pxmPixelType(pxmBytes) == pxmTypeDirect32, @"Incorrect pxm# pixel-type: %hi", pxmPixelType(pxmBytes));

	if (pxmPixelType(pxmBytes) == pxmTypeDirect16 || pxmPixelType(pxmBytes) == pxmTypeDirect32)
	{
		
	}
	else
	return nil;

	//Get the bounds by reference, and compute the width and height from them.
	Rect bounds;
	pxmBounds(pxmBytes, &bounds);
	NSSize size = {
		.width  = bounds.right - bounds.left,
		//QuickDraw Rects are oriented from the top-left, not bottom-left, so bottom is the greater number.
		.height = bounds.bottom - bounds.top
	};

	NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];

	//Assemble information needed by NSBitmapImageRep.
	size_t bitsPerPixel = pxmPixelSize(pxmBytes);
	size_t bytesPerPixel = bitsPerPixel / 8U;

	size_t bytesPerRow = size.width * bytesPerPixel;
	size_t bytesPerFrame = bytesPerRow * size.height;

	size_t samplesPerPixel = pxmHasAlpha(pxmBytes) ? 4U : 3U;

    //Iterate through our â€œframesâ€
	unsigned numFrames = pxmImageCount(pxmBytes);
	NSMutableArray *reps = [NSMutableArray arrayWithCapacity:numFrames];
	
	unsigned i;
	
	for(i = 0U; i < numFrames; ++i) {
		//Passing NULL here makes NSBitmapImageRep allocate its own storageâ€¦
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc]
			initWithBitmapDataPlanes:NULL
			pixelsWide:size.width
			pixelsHigh:size.height
			bitsPerSample:8U
			samplesPerPixel:samplesPerPixel
			hasAlpha:pxmHasAlpha(pxmBytes)
			isPlanar:NO
			colorSpaceName:NSDeviceRGBColorSpace
			bytesPerRow:bytesPerRow
			bitsPerPixel:bitsPerPixel];

		
		if ([bitmapRep size].width != 0 && [bitmapRep size].height != 0)
		{
        //â€¦which we copy into here, from the pixels' address within the pxmRef.
		memcpy([bitmapRep bitmapData], pxmBaseAddressForFrame(pxmBytes, i), bytesPerRow * size.height);

		//Add our new Bitmap Image Rep to the array of representations that will be put in the image.
		[reps addObject:bitmapRep];
		}
		[bitmapRep release];
	}

	//Outfit our image with its representations.
	[image addRepresentations:reps];

	return image;
}

+ (NSImage *)imageFrompxmArrayWithResourceID:(short)resID inResourceFileAtPath:(NSString *)path forkName:(struct HFSUniStr255 *)forkName
{
	//First try to convert the path to a FSRef.
	NSURL *URL = [NSURL fileURLWithPath:path];
	FSRef inputFileRef;
	if(!CFURLGetFSRef((CFURLRef)URL, &inputFileRef)) {
		NSLog(@"In +[NSImage imageFrompxmArrayWithResourceID:inResourceFileAtPath:forkName:]: Could not convert NSURL %@ to FSRef", URL);
		return nil;
	} else {
		//Now try to open the file.
		short resFileHandle = -1;
		OSStatus err = FSOpenResourceFile(
			&inputFileRef,
			//A fork name of "" means the data fork.
			/*forkNameLength*/ forkName ? forkName->length : 0U,
			/*forkName*/ forkName ? forkName->unicode : NULL,
			fsRdPerm,
			&resFileHandle);

		if(resFileHandle < 0) {
			if(err != eofErr) {
				NSLog(@"In +[NSImage imageFrompxmArrayWithResourceID:inResourceFileAtPath:forkName:]: Could not open resource file %@ with fork name %@: %s", path, forkName ? [NSString stringWithCharacters:forkName->unicode length:forkName->length] : nil, GetMacOSStatusCommentString(err));
			}
			return nil;
		}

		//Now retrieve the resource from the freshly-opened file.
		Handle pxmH = Get1Resource(FOUR_CHAR_CODE('pxm#'), resID);
		if(!pxmH) {
			err = ResError();
			NSLog(@"In +[NSImage imageFrompxmArrayWithResourceID:inResourceFileAtPath:forkName:]: Could not get 'pxm#' resource with ID %hi from resource file %@: %s\n", resID, path, GetMacOSStatusCommentString(err));
			CloseResFile(resFileHandle);
			return nil;
		}

		//Create a pxmRef from the resource data.
		pxmRef myPxmRef = pxmCreate(*pxmH, GetHandleSize(pxmH));

		//Create the image that we'll return.
		NSImage *image = [self imageFrompxmArrayData:[NSData dataWithBytesNoCopy:myPxmRef length:GetHandleSize(pxmH) freeWhenDone:NO]];

		//Clean up.
		pxmDispose(myPxmRef);
		ReleaseResource(pxmH);
		CloseResFile(resFileHandle);

		return image;
	}
}

+ (NSImage *)imageFrompxmArrayWithResourceID:(short)resID inResourceFileAtPath:(NSString *)path
{
	NSImage *outImage = nil;
	struct HFSUniStr255 forkNameStorage;

	//First try the resource fork.
	FSGetResourceForkName(&forkNameStorage);
	outImage = [self imageFrompxmArrayWithResourceID:resID inResourceFileAtPath:path forkName:&forkNameStorage];

	//If we manage to create a valid image, return it.
	if(outImage) return outImage;

	//Next, try the data fork.
	FSGetDataForkName(&forkNameStorage);
	outImage = [self imageFrompxmArrayWithResourceID:resID inResourceFileAtPath:path forkName:&forkNameStorage];

	//Return whatever we have.
	return outImage;
}

+ (NSImage *)imageFrompxmArrayInSearchPathWithResourceID:(short)resID
{
	//Now retrieve the resource from the freshly-opened file.
	Handle pxmH = GetResource(FOUR_CHAR_CODE('pxm#'), resID);
	if(!pxmH) {
		OSStatus err = ResError();
		NSLog(@"In +[NSImage imageFrompxmArrayInSearchPathWithResourceID:]: Could not get 'pxm#' resource with ID %hi: %s\n", resID, GetMacOSStatusCommentString(err));
		return nil;
	}

	//Create the image that we'll return.
	pxmRef myPxmRef = pxmCreate(*pxmH, GetHandleSize(pxmH));
	NSImage *image = [self imageFrompxmArrayData:[NSData dataWithBytesNoCopy:myPxmRef length:GetHandleSize(pxmH) freeWhenDone:NO]];

	//Clean up.
	pxmDispose(myPxmRef);
	ReleaseResource(pxmH);

	return image;
}

#if defined(__BIG_ENDIAN__)
	#define EXTRAS_DOT_RSRC_PATH "/System/Library/Frameworks/Carbon.framework/Frameworks/HIToolbox.framework/Resources/Extras.rsrc"
#elif defined(__LITTLE_ENDIAN__)
	#define EXTRAS_DOT_RSRC_PATH "/System/Library/Frameworks/Carbon.framework/Frameworks/HIToolbox.framework/Resources/Extras2.rsrc"
#endif

+ (NSImage *)imageFromSystemwidepxmArrayWithResourceID:(short)resID
{
  //Extras.rsrc stores its resources in the data fork, which we can get by passing NULL
  return [self imageFrompxmArrayWithResourceID:resID inResourceFileAtPath:EXTRAS_DOT_RSRC_PATH forkName:NULL];
}


@end
