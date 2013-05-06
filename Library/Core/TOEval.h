//
//  TOEval.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//
#import <Foundation/Foundation.h>
@class 		TOMem;
@protocol	TODelegate;	
@interface 	TOEval 			: NSObject
@property (nonatomic,strong) NSArray	*statement;
@property (nonatomic,strong) TOMem 		 *mem;
@property (nonatomic,strong) NSString 	 *source;
@property (nonatomic,weak)id<TODelegate> delegate;
-   (id) eval;
- (void) abort;
-   (id) initWithStatement:(NSArray*)statement mem:(TOMem*)mem;
+   (id) evalStatement:		(NSArray*)statement;
@end
