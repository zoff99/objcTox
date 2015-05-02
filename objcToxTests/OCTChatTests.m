//
//  OCTChatTests.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 25.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "OCTChat.h"
#import "OCTChat+Private.h"
#import "OCTMessageAbstract+Private.h"

@interface OCTChatTests : XCTestCase

@end

@implementation OCTChatTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHasUnreadMessages
{
    OCTChat *chat = [OCTChat new];

    chat.lastMessage = [OCTMessageAbstract new];
    chat.lastMessage.date = [NSDate dateWithTimeIntervalSinceNow:10];

    XCTAssertTrue([chat hasUnreadMessages]);

    [chat updateLastReadDateToNow];
    chat.lastMessage = nil;

    XCTAssertFalse([chat hasUnreadMessages]);

    chat.lastMessage = [OCTMessageAbstract new];
    chat.lastMessage.date = [NSDate dateWithTimeIntervalSinceNow:10];

    XCTAssertTrue([chat hasUnreadMessages]);

    chat.lastMessage.date = [NSDate dateWithTimeIntervalSinceNow:-10];

    XCTAssertFalse([chat hasUnreadMessages]);
}

@end