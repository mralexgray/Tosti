
//#import "AZBeetljuice.h"
#import "TOCocoaAppDelegate.h"

@implementation TOCocoaAppDelegate 
{ id eventHandler; }

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification	{

	_tokensForCompletion = [[NSArray arrayWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"Keywords" ofType:@"plist"]] mutableCopy];
	//	[NSMutableArray arrayWithObjects:@"A very long keyword",@"Änger",@"Blatt",@"test",@"tiara",@"typhoon",@"trick",@"trigger",@"tiger",@"@tickle",@"@waiting",@"@Followup",@"Walrus", nil];  
	[_myTokenField setTokenArray:@[@"test"]];
	[_tableView reloadData];
	_console.string = @"Enter 'help' for help.\n";
	_editor.editable = YES;
//  	_console.textStorage.font = [NSFont fontWithName:@"UbuntuMono-Bold" size:18];
//	_editor.font = [NSFont fontWithName:@"UbuntuMono-Bold" size:18];//[NSFont fontWithName:@"Menlo" size:11]];
	 [_window makeFirstResponder:_editor];
	
	_controller = TOConsoleController.new;
	[(NSObject*)_controller performSelector:@selector(setup)];
	_controller.delegate = self;
	self.messageVisible = NO;
	_messageTextView.textColor = NSColor.whiteColor;
	_messageTextView.font =  [NSFont fontWithName:@"UbuntuMono-Bold" size:18];
//	AZBeetlejuiceLoadAtoZ();
//
	[@[_consoleSplit, _messageView, _messageTextView, _console, _myTokenField, _tableView, _editor]makeObjectsPerformSelector:@selector(debug)];


}
- (BOOL)textView:(NSTextView*)tv shouldChangeTextInRange:(NSRange)affR replacementString:(NSString*)rplc	{
	
//	NSLog(@"TVProps:%@. \n%@:%@", [tv valueForKey:@"properties"], NSStringFromRange(affR), rplc);
   return [_controller shouldType:rplc];
}
#pragma mark - TOConsoleTextDelegate

- (NSString*) input 														{	/*BMAIN;*/ return [_editor.string copy]; 				}
-      (void) setInput:                   (NSString*)input	{	/*BMAIN;*/         _editor.string = [input copy];	}
-      (void) append: 						   (NSString*)text	{	[_console safeAppendAndFollowText:text];
//	NSLog(@":%@", text); 	[_console safeAppendAndFollowText:text];
}
-      (void) appendAttributed: (NSAttributedString*)text 	{	[_console safeAppendAndFollowAttributedText:text];
//	[att appendAttributedString:text];//	[(NSTextStorage*)[_console textStorage] setAttributedString:att];
}

- (void) insertImage:		(NSImage*)image 			{

  	NSTextAttachment *attachment = NSTextAttachment.alloc.init;
   NSTextAttachmentCell *cell = [NSTextAttachmentCell.alloc initImageCell:image];
	[cell setImage: image];
	NSMutableAttributedString *prettyName = (id)[NSMutableAttributedString attributedStringWithAttachment:attachment]; // cast to quiet compiler warning
	[[_console textStorage] appendAttributedString: prettyName];

}
- (void) setMessageVisible:(BOOL*)messageVisible	{
/*
	NSRect right, left;   left	= right = [_consoleSplit bounds];
	CGFloat slideAmount 			= _consoleSplit.frame.size.width / 4;

	if (!messageVisible) {
		right.origin.x 	= left.size.width;
		right.size.width 	= 0;
	} else {
		right.origin.x  	= left.size.width - slideAmount;
		right.size.width 	= slideAmount;
		left.size.width 	-= slideAmount;
	}

	if (messageVisible) {
		void (^oneFrom)(void);
		oneFrom = ^{	NSLog(@"Removing handler"); [NSEvent removeMonitor:eventHandler];	};
		eventHandler = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *w) {
			self.messageVisible = NO;	 oneFrom();  return w;		
		}];
	}
	[NSAnimationContext beginGrouping];
	[_console.animator 		setFrame:left];
	[_messageView.animator 	setFrame:right];
//	[_messageView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		[obj setFrame:NSMakeRect(0,0,right.size.width, right.size.height)];
//	}];
	[NSAnimationContext endGrouping];
	*/
}
- (void) showMessage:		(NSString*)text			{ 
	self.messageVisible = YES; _messageTextView.string = text; 
}

- (NSInteger) numberOfRowsInTableView:(NSTableView*)tableView													{	return [self.tokensForCompletion count];}
- (id) tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn*)tc row:(NSInteger)r 	{ return self.tokensForCompletion[r];	}

- (NSArray*)tokenField:(MTTokenField*)tokenField completionsForSubstring:(NSString*) substring 		{
//	if (self.option==0){  // matching substring to anyportion of the candidate
	__block NSMutableArray * matches = NSMutableArray.new;
	[self.tokensForCompletion enumerateObjectsUsingBlock:^(NSString *candidate, NSUInteger idx, BOOL *stop) {
			[candidate rangeOfString:substring options:NSCaseInsensitiveSearch].location !=NSNotFound
		?	[matches addObject:candidate] : nil;
	}];
   return matches;
}
- (NSMenu*) tokenField:(MTTokenField*)tf menuForToken:(NSString*)str atIndex:(NSUInteger)idx			{
	__block NSMenu *test 			= NSMenu.new;
	[@[@"Cut",@"Copy",@"Paste",@"-", [NSString stringWithFormat:@"Add %@ to preferences",str]]enumerateObjectsUsingBlock:^(NSString *aName, NSUInteger idx, BOOL *stop) {
		if ([aName isEqualToString:@"-"]) [test addItem:NSMenuItem.separatorItem];
		else{
			NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:aName action:@selector(action:) keyEquivalent:@""];
			[item setTarget:self];
			[test addItem:item];		
		}
	}];
	return test;
}
- (void)   action:(id)sender	{	NSLog(@"You selected Menu Item: %@",sender);	}
- (IBAction)click:(id)sender	{	[_myTokenField setTokenArray:@[@"blatt"]];	}

- (CGFloat)splitView:(NSSplitView*)sv constrainMaxCoordinate:(CGFloat)min ofSubviewAt:(NSInteger)divIdx {    return min - 60;	}
@end

/*
gdb instrumentObjcMessageSends(YES);
- (NSDictionary*)defaultAttributes {
	return @{	NSFontNameAttribute : [NSFont fontWithName:@"UbuntuMono-Bold" size:18],
					NSUnderlineStyleAttributeName : @(NSUnderlinePatternDot),
					NSUnderlineColorAttributeName : NSColor.redColor,
					NSForegroundColorAttributeName : [NSColor colorWithCalibratedRed:0.869 green:0.615 blue:0.220 alpha:1.000] }.copy;
}

else{
		// matching substring to leading characters of candidate ignoring any non AlphaNumeric characters in candidate
		// eg
		// if substring is "ac",   matches will include "@action" and "account" but not "fact"
		
		NSRange alphaNumericRange = [substring rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
		NSString * alphaSubstring = @"";
		
		BOOL searchFullString = NO;
		if (alphaNumericRange.location!=NSNotFound){
			alphaSubstring = [substring substringFromIndex:alphaNumericRange.location];
		}
		else{
			alphaSubstring = substring;
			searchFullString = YES;
		}
		
		NSMutableArray * matches = [[NSMutableArray alloc] init];;
		for (NSString *candidate in testArray){
			// remove any candidate already in use
			if ([tokenField respondsToSelector:@selector(tokenArray)]){
				if([[tokenField tokenArray] containsObject:candidate]) continue;
			}
			else{
				if([[tokenField objectValue] containsObject:candidate]) continue;
			}
			
			
			
			NSRange alphaNumericRange = [candidate rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
			if (alphaNumericRange.location!=NSNotFound){
				NSString * alphaKeyword = searchFullString?candidate:[candidate substringFromIndex:alphaNumericRange.location];
				NSRange substringRange = [alphaKeyword rangeOfString:alphaSubstring options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
				if (substringRange.location == 0){
					[matches addObject:candidate];
				}
			}
			
		}
		
		return matches; 
	}
	
}
*/