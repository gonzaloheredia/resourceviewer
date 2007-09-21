//
//  AppController.h
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVResource.h"
#import "RVApplication.h"

#import "RVSourceTableView.h"
#import "RVImageView.h"
#import "RVImageEditorView.h"

@interface AppController : NSObject {


short res;

NSMutableDictionary *typesMasterDictionary;
NSMutableArray *currentTypeEntriesMasterArray;

NSString *currentResourceFilePath;

IBOutlet RVImageView * _typeEntriesIconView;
IBOutlet NSTextView *_dataEditor;
IBOutlet NSTextView *_hexEditor;

IBOutlet RVImageEditorView *_imageEditor;

IBOutlet NSView *_iconView;
IBOutlet NSView *_dataEditorView;
IBOutlet NSView *_imageEditorView;

IBOutlet NSView *_mainTabView;

IBOutlet NSProgressIndicator* _loadingIndicator;
IBOutlet NSWindow* _loadingWindow;

IBOutlet NSWindow* _mainWindow;
IBOutlet RVSourceTableView* _sourceTableView;
IBOutlet NSSplitView *_mainSplitView;

}
-(IBAction )returnToIconView:(id)sender;

-(IBAction)openFile:(id)sender;
-(IBAction)saveAllResources:(id)sender;

-(IBAction)resizeImages:(id)sender;

-(void)goToEditorViewForResource:(NSDictionary *)res;
-(void)goToImageEditorViewForResource:(NSDictionary *)res;
-(void)goToDataEditorViewForResource:(NSDictionary *)res;

@end
