#import <XCTest/XCTest.h>
#define HC_SHORTHAND 1
#import <OCHamcrest/OCHamcrest.h>

#import "NSIndexSet+BKReduce.h"

@interface NSIndexSet_BKReduceTests : XCTestCase

@end

@implementation NSIndexSet_BKReduceTests

- (void)testReduce {
    NSIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
    assertThat([indexes wmf_reduce:[NSMutableArray new]
                         withBlock:^id(NSMutableArray *acc, NSUInteger idx) {
                             [acc addObject:@(idx)];
                             return acc;
                         }],
               is(@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9]));
}

- (void)testBadInput {
    assertThat([[NSIndexSet indexSet] wmf_reduce:nil
                                       withBlock:^id(id _, NSUInteger __) {
                                           return nil;
                                       }],
               is(nilValue()));

    id input = [NSMutableArray new];
    assertThat([[NSIndexSet indexSet] wmf_reduce:input withBlock:nil], is(input));
}

@end
