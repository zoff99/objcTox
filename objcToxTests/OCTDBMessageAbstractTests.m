//
//  OCTDBMessageAbstractTests.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "OCTDBMessageAbstract.h"
#import "OCTFriend+Private.h"
#import "OCTMessageText+Private.h"
#import "OCTMessageFile+Private.h"
#import "OCTMessageAbstract+Private.h"
#import "Realm.h"

@interface OCTDBMessageAbstractTests : XCTestCase

@end

@implementation OCTDBMessageAbstractTests

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

- (void)testInitText
{
    OCTFriend *friend = [OCTFriend new];
    friend.friendNumber = 5;

    OCTMessageText *message = [OCTMessageText new];
    message.date = [NSDate date];
    message.isOutgoing = YES;
    message.sender = friend;
    message.text = @"text";
    message.isDelivered = YES;

    id sender = OCMClassMock([OCTDBFriend class]);

    OCTDBMessageAbstract *db = [[OCTDBMessageAbstract alloc] initWithMessageAbstract:message sender:sender];

    XCTAssertNotNil(db);
    XCTAssertNotNil(db.textMessage);
    XCTAssertEqual(db.dateInterval, [message.date timeIntervalSince1970]);
    XCTAssertEqual(db.isOutgoing, message.isOutgoing);
    XCTAssertEqual(db.sender, sender);
    XCTAssertEqualObjects(db.textMessage.text, message.text);
    XCTAssertEqual(db.textMessage.isDelivered, message.isDelivered);
}

- (void)testInitFile
{
    OCTFriend *friend = [OCTFriend new];
    friend.friendNumber = 5;

    OCTMessageFile *message = [OCTMessageFile new];
    message.date = [NSDate date];
    message.isOutgoing = YES;
    message.sender = friend;
    message.fileType = OCTMessageFileTypeReady;
    message.fileSize = 100;
    message.fileName = @"fileName";
    message.filePath = @"filePath";
    message.fileUTI = @"fileUTI";

    id sender = OCMClassMock([OCTDBFriend class]);

    OCTDBMessageAbstract *db = [[OCTDBMessageAbstract alloc] initWithMessageAbstract:message sender:sender];

    XCTAssertNotNil(db);
    XCTAssertNotNil(db.fileMessage);
    XCTAssertEqual(db.dateInterval, [message.date timeIntervalSince1970]);
    XCTAssertEqual(db.isOutgoing, message.isOutgoing);
    XCTAssertEqual(db.sender, sender);
    XCTAssertEqual(db.fileMessage.fileType, message.fileType);
    XCTAssertEqual(db.fileMessage.fileSize, message.fileSize);
    XCTAssertEqualObjects(db.fileMessage.filePath, message.filePath);
    XCTAssertEqualObjects(db.fileMessage.filePath, message.filePath);
    XCTAssertEqualObjects(db.fileMessage.fileUTI, message.fileUTI);
}

@end