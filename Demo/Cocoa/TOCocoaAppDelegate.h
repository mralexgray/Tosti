//  TOCocoaAppDelegate.h
//  TostiCocoaDemo

//#import "MTTokenField.h"
#import <AtoZ/AtoZ.h>
#import "TOConsoleController.h"

@interface TOCocoaAppDelegate : NSObject 	<	NSApplicationDelegate, 
															NSTextViewDelegate, 
															TOConsoleTextDelegate, 
															NSTableViewDataSource,
															MTTokenFieldDelegate		>
@property (assign) IBOutlet NSWindow 		*window;

	
@property (nonatomic) 		 BOOL 			*messageVisible;
@property (assign) IBOutlet NSView 			*consoleSplit;
@property (assign) IBOutlet NSView 			*messageView;
@property (assign) IBOutlet NSTextView 	*messageTextView;

@property (assign) IBOutlet NWLLogView 	*console;
@property (assign) IBOutlet MTTokenField 	*myTokenField;
@property (assign) IBOutlet NSTableView 	*tableView;
@property (assign) IBOutlet NWLLogView 	*editor;

@property (strong) TOConsoleController *controller;
@property (strong) NSMutableArray		*tokensForCompletion;

@property (readonly) NSDictionary 		*defaultAttributes;

//	TOConsoleTextDelegate
@property (nonatomic, strong) NSString *input;
- (void)	appendAttributed: (NSAttributedString*)text;
- (void) append:				(NSString*)text;
- (void) insertImage:(NSImage*)image;

@end
