//
//  TOTestIntegration.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"
@interface TOTestIntegration : SenTestCase <TODelegate> @end
@implementation TOTestIntegration {
	NSString *_logs;
	TOMem *_mem;
}
- (void)setUp
{
	[super setUp];
	_logs = @"";
	_mem = [[TOMem alloc] init];
}
- (void)log:(NSString*)line
{
	_logs = [_logs stringByAppendingFormat:@"%@\n", line];
}
- (void)eval:(NSString*)code
{
	[_mem eval:code delegate:self];
}
- (void)testArrayAverage
{
	[self eval:@"id a = @ [ @ 1 , @ 2 , @ 4 ] ; __block id x = @ 0 ; [ TO for : ^ ( id i ) { x = TOMath.add ( @ [ x , a[ [ i integerValue ] ] ] ) ; } to : @ ( [ a count ] ) ] ;"];
	STAssertEqualObjects([_mem get:@"x"], @7, @"");
	[self eval:@"a=@[1 2 6]x=0 [TO for:^(i){x=TOMath.add(x a[i])} to:a.count]x=TOMath.div(x,a.count)"];
	STAssertEqualObjects([_mem get:@"x"], @3, @"");
	STAssertEqualObjects(_logs, @"", @"");
}
- (void)testMeta
{
	[self eval:@"x=3"];
	STAssertEqualObjects([_mem get:@"x"], @3, @"");
	[self eval:@"mem = [[TOMem alloc] init];[mem eval:'x=3'];y=[mem get:'x'];"];
	STAssertEqualObjects([_mem get:@"y"], @3, @"");
	[self eval:@"mem = [[TOMem alloc] init];[mem eval:'mem = [[TOMem alloc] init];[mem eval:\\'x=3\\'];y=[mem get:\\'x\\'];'];z=[mem get:'y'];"];
	STAssertEqualObjects([_mem get:@"z"], @3, @"");
	STAssertEqualObjects(_logs, @"", @"");
}
@end
