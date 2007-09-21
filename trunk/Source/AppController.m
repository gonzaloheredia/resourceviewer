//
//  AppController.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import <CoreServices/CoreServices.h>

static enum _RVMainViews {

	RVIconView = 0,
	RVDataEditorView,
	RVImageEditorView

} RVMainViews;

@implementation AppController

-(void)awakeFromNib
{

	[self drawMetalWindow];
	
	
	NSNotificationCenter *nc =[NSNotificationCenter defaultCenter];
	
		[nc addObserver:self
		   selector:@selector(drawMetalWindow)
			   name:NSWindowDidResizeNotification
			 object:_mainWindow];
	
	[nc addObserver:self
			   selector:@selector(processTypeSelection)
				   name:NSOutlineViewSelectionIsChangingNotification
				 object:_sourceTableView];
			 
	[_typeEntriesIconView setController:self];
	
	/* Zero out the tabview */
	
	int i = 0;
	
	while (i < [[_mainTabView tabViewItems] count])
	{
	[_mainTabView removeTabViewItem:[[_mainTabView tabViewItems] objectAtIndex:i]];
	
	i++;
	}
		
	int j = 0;
	
	/* Put all our views in the tab view */
	 
	NSArray *__mainViewArray = [[NSArray arrayWithObjects:_iconView, _dataEditorView, _imageEditorView, nil] retain];


	while (j < [__mainViewArray count])
	{
	
	NSView * currentView = [__mainViewArray objectAtIndex:j];
	
	NSTabViewItem *currentTabViewItem = [NSTabViewItem new];
	
	[currentTabViewItem setView:currentView];
	
	[_mainTabView addTabViewItem:currentTabViewItem];
	j++;
	}
	
	[__mainViewArray release];
	 
}

-(void)importResourceForType:(NSString *)typeName
{
	[_loadingIndicator startAnimation:self];

	[[NSApplication sharedApplication] beginSheet:_loadingWindow modalForWindow:_mainWindow modalDelegate:self didEndSelector:nil contextInfo:nil];

	[currentTypeEntriesMasterArray removeAllObjects];

	[currentTypeEntriesMasterArray release];
	currentTypeEntriesMasterArray = [[NSMutableArray array] retain];

	ResType currentResourceType = NSResTypeFromString(typeName);
			
			SInt16 count = CountResources(currentResourceType);
			
			[_loadingIndicator setMaxValue:[[NSNumber numberWithInt:count] doubleValue]];
			
			int i;			
			for (i = 1; i <= count; i++)
			{
				[_loadingIndicator setDoubleValue:[[NSNumber numberWithInt:i] doubleValue]];
				
				Handle rsrcHandle = GetIndResource(currentResourceType, i);
				
				Str255 pascStr;
				ResType type;
				ResID resID;
				GetResInfo(rsrcHandle, &resID, &type, pascStr);
				NSString *name = NSPascalStringGetString((ConstStringPtr)pascStr);
										
				NSData  *data = [NSData dataWithBytes: *rsrcHandle length: NSUnsignedIntFromSize(GetHandleSize(rsrcHandle))];
				
				RVResource *currentResource = [RVResource new];
				currentResource.type = typeName;
				currentResource.name = name;
				currentResource.identifier = resID;
				currentResource.index = [[NSNumber numberWithInt:i] stringValue];
				currentResource.data = data;
				
				[currentTypeEntriesMasterArray addObject:currentResource];
			}
			
			[[NSApplication sharedApplication] endSheet:_loadingWindow];
			[_loadingWindow orderOut:self];
			[_loadingIndicator stopAnimation:self];
			
			/* Update our image viewer */
			[_typeEntriesIconView setSource:currentTypeEntriesMasterArray];
}

-(void)importAllPICTResources
{
	
	[self importResourceForType:@"PICT"];

}

#define ResourceCount int

-(void)listAllTypes
{
		ResourceCount typeC = CountTypes();
		
		int i;
		
		NSLog(@"Discovered %i Resource Types", typeC);
		
		[typesMasterDictionary release];
		typesMasterDictionary = [NSMutableDictionary dictionary];
		
		NSMutableArray *imageResourceTypes  = [[NSMutableArray array] retain];
		NSMutableArray *unhandledResourceTypes  = [[NSMutableArray array] retain];

		for (i = 1; i <= typeC; i++)
			{
				ResType currentType;
				GetIndType(&currentType, i);
				BOOL wasHandled = NO;
				
				NSString *typeName = NSStringFromResType(currentType);		
				
				int st = 0;
				while (st < [supportedImageResourceTypes() count])
				{
				NSString *supportedType = [supportedImageResourceTypes() objectAtIndex:st];
				
				if (NSStringsAreEqual(supportedType, typeName))
					{
						[imageResourceTypes addObject:[typeName retain]];
						wasHandled = YES;
						break;
					}	
					st++;
				}
				
				
				if (!wasHandled)
				[unhandledResourceTypes addObject:[typeName retain]];
			}

		
		[typesMasterDictionary setObject:imageResourceTypes forKey:@"Images"];

		[typesMasterDictionary setObject:unhandledResourceTypes forKey:@"Other"];
		
		[typesMasterDictionary retain];
		
		
		NSLog([typesMasterDictionary description]);

		[_sourceTableView setDataSource:self];
		[_sourceTableView reloadData];
				
}

-(void)readFile
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	CloseResFile(res);
	
	[_mainWindow setTitleWithRepresentedFilename:currentResourceFilePath];
	
	FSRef ref;
	
    if (FSPathMakeRef ((const UInt8 *)[currentResourceFilePath fileSystemRepresentation], &ref, NULL)
        == noErr)
		{
        res = FSOpenResFile (&ref, fsRdPerm);
		
        if (ResError() == noErr)
        {
			[self listAllTypes];			
		}
		else
		{
			NSLog(@"No resource fork found, opening data fork instead");
			
			HFSUniStr255 forkName;
			
			OSErr Rerror;
			OSErr Derror;

			Rerror = FSGetResourceForkName(&forkName);
			
			ConstHFSUniStr255Param fName = &forkName;


				Derror = FSGetDataForkName(&forkName);
				if (Derror == noErr) {
			
					FSOpenResourceFile(&ref, fName->length, fName->unicode, fsRdPerm, &res);
				
					[self listAllTypes];		
				
			}
			


			
			
			
		
		}
	}

	[pool release];
}

-(IBAction)openFile:(id)sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: YES];
    [panel setCanChooseDirectories: YES ];
    [panel beginSheetForDirectory: nil file: nil types: nil
        modalForWindow: _mainWindow modalDelegate: self
        didEndSelector: @selector( openSheetDidEnd:returnCode:contextInfo: )
        contextInfo: nil];  
}

- (void) openSheetDidEnd: (NSOpenPanel *) sheet returnCode: (int)
    returnCode contextInfo: (void *) contextInfo
{
    if( returnCode != NSOKButton )
        return;

    if( currentResourceFilePath )
        [currentResourceFilePath release];
		currentResourceFilePath = [[[sheet filenames] objectAtIndex: 0] retain];
		
	[[NSApplication sharedApplication] endSheet:sheet];
	[sheet orderOut:self];

		
	[NSThread detachNewThreadSelector:@selector(readFile) toTarget:self withObject:nil];
}

#pragma mark -

CGImageRef CGImageRefFromNSData(NSData *imageData)
{
	CGImageRef _image;
	CGImageSourceRef _source;
	
	_source =CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);


	_image = CGImageSourceCreateImageAtIndex(_source, 0, (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,(NSString *)kCGImageSourceShouldAllowFloat, nil]);
		
	CFRetain(_image);
	CFRelease(_source);
	
	return _image;

}

-(IBAction )returnToIconView:(id)sender
{

	[_mainTabView selectTabViewItemAtIndex:RVIconView];
	
	
}

-(void)goToEditorViewForResource:(RVResource *)res
{

if ([supportedImageResourceTypes() containsObject:res.type])
	[self goToImageEditorViewForResource:res];
else
	[self goToDataEditorViewForResource:res];

}


-(void)goToImageEditorViewForResource:(RVResource *)res
{
	[_imageEditor setImage:[[RVApplication sharedApplication] imageForResource:res]];
	
	
	[_mainTabView selectTabViewItemAtIndex:RVImageEditorView];

}

#pragma mark -


NSString * makeHex(NSString *inS)
{
	char*				byteHead;
	
	NSString *hexString = @"";
		
	byteHead = (char*)[[inS dataUsingEncoding:NSMacOSRomanStringEncoding] bytes];
	long index;
	
	long size = (long)CFDataGetLength((CFDataRef)[inS dataUsingEncoding:NSMacOSRomanStringEncoding]);
		
	// now draw the bytes in clumps of 2
	for ( index = 0; index <  size; index += 2 )
	{

		// If there are 2 bytes to draw cluster them together
		if ( ( size - index ) >= 2 )
		{			
			hexString = [hexString stringByAppendingFormat:@"%02X%02X ", byteHead[0] & 0xFF, byteHead[1] & 0xFF ];
		}
		else	// there is only 1 byte to draw
		{
			hexString = [hexString stringByAppendingFormat:@"%02X", byteHead[0] & 0xFF];
		}
		
			byteHead	+= 2;

	}
		
		return hexString;
	
}

-(void)goToDataEditorViewForResource:(RVResource *)res
{
	
	NSString *dataStr = [[[NSString alloc] initWithData:res.data encoding:NSMacOSRomanStringEncoding] retain];

	NSString *hexStr = [makeHex(dataStr) retain];

	[_hexEditor setString:hexStr];
	[_dataEditor setString:dataStr];
	[_mainTabView selectTabViewItemAtIndex:RVDataEditorView];

}


#pragma mark -

-(IBAction)resizeImages:(id)sender
{
	[_typeEntriesIconView setZoomValue:[sender floatValue]/100.0];	
	
	//[_imageEditor setZoomFactor:[sender floatValue]/100.0f];
}

#pragma mark -

-(IBAction)saveAllResources:(id)sender
{
 NSSavePanel * panel = [NSSavePanel savePanel];
	[panel setNameFieldLabel:@"Save In:"];

      [panel beginSheetForDirectory: nil file: nil
        modalForWindow: _mainWindow modalDelegate: self
        didEndSelector: @selector( saveSheetDidEnd:returnCode:contextInfo: )
        contextInfo: nil];  
}

- (void) saveSheetDidEnd: (NSOpenPanel *) sheet returnCode: (int)
    returnCode contextInfo: (void *) contextInfo
{
    if( returnCode != NSOKButton )
        return;
		
	if (![[NSFileManager defaultManager] fileExistsAtPath:[sheet filename]])
	{
		
		[[NSFileManager defaultManager] createDirectoryAtPath:[sheet filename] attributes:nil];
	
	}	
	

		int cr = 0;
				while (cr < [currentTypeEntriesMasterArray count])
				{
				
				RVResource *currentRes = [currentTypeEntriesMasterArray objectAtIndex:cr];
				
					NSString *t = currentRes.type;
	
		if (NSStringsAreEqual(t, @"PICT"))
			[currentRes.data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.pct", [sheet filename] , currentRes.index, currentRes.name] atomically:NO];
	
		else if (NSStringsAreEqual(t, @"kcns"))
			[currentRes.data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.icns", [sheet filename] , currentRes.index, currentRes.name] atomically:NO];

		else if (NSStringsAreEqual(t, @"icns"))
			[currentRes.data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.icns", [sheet filename] , currentRes.index, currentRes.name] atomically:NO];
			
		else if (NSStringsAreEqual(t, @"PNGf"))
			[currentRes.data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.png", [sheet filename] , currentRes.index, currentRes.name] atomically:NO];
	
		else
			[currentRes.data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.dat", [sheet filename] , currentRes.index, currentRes.name] atomically:NO];


				cr++;
				}

}
#pragma mark -
#pragma mark Table Select

-(void)processTypeSelection
{
	NSString *wantedType = [_sourceTableView itemAtRow:[_sourceTableView selectedRow]];//[typesMasterArray objectAtIndex:[_sourceTableView selectedRow]];
	
	if ([_sourceTableView parentForItem:wantedType])
		[self importResourceForType:wantedType];

}



#pragma mark -
#pragma mark Source Table Datasource

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == NULL) // Root
		return [[typesMasterDictionary allKeys] count];
	else
		return [[typesMasterDictionary objectForKey:item] count];
}
 
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([[typesMasterDictionary objectForKey:item] respondsToSelector:@selector(count)])
		return YES;
	else
		return NO;
}
 
- (id)outlineView:(NSOutlineView *)outlineView
    child:(int)index
    ofItem:(id)item
{
	if (item == NULL)
		return [[typesMasterDictionary allKeys] objectAtIndex:index];
	else 
		return [[typesMasterDictionary objectForKey:item] objectAtIndex:index];
}
 
- (id)outlineView:(NSOutlineView *)outlineView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
    byItem:(id)item
{
	return item;
}

#pragma mark Source Table Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{

if ([outlineView isExpandable:item])
return NO;
else
return YES;
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{

	if ([supportedImageResourceTypes() containsObject:[cell stringValue]])
	{
		[cell setIsCategory:NO];
		
		#if 0
		[cell setImage:[[NSImage imageNamed:@"SourcePICT"] retain]];	// Crashes Tiger, will investigate
		#endif
		
	}
	else if ([outlineView isExpandable:item])
	{
		[cell setIsCategory:YES];

	}
	else
	{
		[cell setIsCategory:NO];
		
		#if 0
		[cell setImage:[[NSImage imageNamed:@"SourceFolder"] retain]];		// Crashes Tiger, will investigate
		#endif

	}
		
}

#pragma mark -
#pragma mark TIGER

-(void)drawMetalWindow
{	
	NSColor *bgColor = [_mainWindow backgroundColor];
    NSImage *bg = [[NSImage alloc] initWithSize:[_mainWindow frame].size];
    
    [bg lockFocus];
    
    // Composite current background color into bg
	[[NSColor colorWithCalibratedRed:187.0/255.0 green:188.0/255.0 blue:187.0/255.0 alpha:1.0] set];
		
    NSRectFill(NSMakeRect(0, 0, [bg size].width, [bg size].height));
    
    // Composite top-left and top-right images
    NSImage *topLeft = [NSImage imageNamed:@"top_left"];
    [topLeft compositeToPoint:NSMakePoint(0, [bg size].height - [topLeft size].height) 
                    operation:NSCompositeSourceOver];
    NSImage *topRight = [NSImage imageNamed:@"top_right"];
	
    [topRight compositeToPoint:NSMakePoint([bg size].width - [topRight size].width, 
										   [bg size].height - [topRight size].height) 
                     operation:NSCompositeSourceOver];
    
    // Composite top-middle "pattern"
    NSColor *topMiddle = [NSColor colorWithPatternImage:[NSImage imageNamed:@"top_middle"]];
    [topMiddle set];
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint([bg size].width, [bg size].height)];
	
	NSRectFill(NSMakeRect([topLeft size].width, [bg size].height - [topLeft size].height, 
                          [bg size].width - [topLeft size].width - [topRight size].width, 
                          [topLeft size].height));
	   
    // Composite bottom-left and bottom-right images
    NSImage *bottomLeft = [NSImage imageNamed:@"bottom_middle"];
    [bottomLeft compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
    NSImage *bottomRight = [NSImage imageNamed:@"bottom_middle"];
    [bottomRight drawInRect:NSMakeRect([bg size].width - [bottomRight size].width, 0,[bottomRight size].width, 55) fromRect:NSZeroRect
				  operation:NSCompositeSourceOver fraction:1.0];
    
    // Composite bottom-middle "pattern"
    NSColor *bottomMiddle = [NSColor colorWithPatternImage:[NSImage imageNamed:@"bottom_middle"]];
    [bottomMiddle set];
    [[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint([bottomLeft size].width, 55)];
    NSRectFill(NSMakeRect([bottomLeft size].width, 0, 
                          [bg size].width - [bottomLeft size].width - [bottomRight size].width, 
                          55));
    
    [bg unlockFocus];
    
    [_mainWindow setBackgroundColor:[NSColor colorWithPatternImage:bg]];
    
    [bg release];
	
}


@end
