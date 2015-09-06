//
//  OCTManager.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 06.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objc/runtime.h>

#import "OCTManager.h"
#import "OCTTox.h"
#import "OCTManagerConfiguration.h"
#import "OCTSubmanagerAvatars+Private.h"
#import "OCTSubmanagerBootstrap+Private.h"
#import "OCTSubmanagerChats+Private.h"
#import "OCTSubmanagerDNS+Private.h"
#import "OCTSubmanagerFiles+Private.h"
#import "OCTSubmanagerFriends+Private.h"
#import "OCTSubmanagerObjects+Private.h"
#import "OCTSubmanagerUser+Private.h"
#import "OCTRealmManager.h"

@interface OCTManager () <OCTToxDelegate, OCTSubmanagerDataSource>

@property (strong, nonatomic, readonly) OCTTox *tox;
@property (copy, nonatomic, readonly) OCTManagerConfiguration *configuration;

@property (strong, nonatomic, readwrite) OCTSubmanagerAvatars *avatars;
@property (strong, nonatomic, readwrite) OCTSubmanagerBootstrap *bootstrap;
@property (strong, nonatomic, readwrite) OCTSubmanagerChats *chats;
@property (strong, nonatomic, readwrite) OCTSubmanagerDNS *dns;
@property (strong, nonatomic, readwrite) OCTSubmanagerFiles *files;
@property (strong, nonatomic, readwrite) OCTSubmanagerFriends *friends;
@property (strong, nonatomic, readwrite) OCTSubmanagerObjects *objects;
@property (strong, nonatomic, readwrite) OCTSubmanagerUser *user;

@property (strong, nonatomic) OCTRealmManager *realmManager;

@property (strong, nonatomic, readonly) NSObject *toxSaveFileLock;

@property (strong, atomic) NSNotificationCenter *notificationCenter;

@end

@implementation OCTManager

#pragma mark -  Lifecycle

- (instancetype)initWithConfiguration:(OCTManagerConfiguration *)configuration error:(NSError **)error
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self validateConfiguration:configuration];
    _configuration = [configuration copy];

    [self createNotificationCenter];
    [self importToxSaveIfNeeded];

    NSData *savedData = [self getSavedData];

    if (! [self createToxWithSavedData:savedData error:error]) {
        return nil;
    }

    [self createRealmManager];
    [self createSubmanagers];

    return self;
}

- (void)dealloc
{
    [self.tox stop];
}

#pragma mark -  Public

- (NSString *)exportToxSaveFile:(NSError **)error
{
    @synchronized(self.toxSaveFileLock) {
        NSString *savedDataPath = self.configuration.fileStorage.pathForToxSaveFile;
        NSString *tempPath = self.configuration.fileStorage.pathForTemporaryFilesDirectory;
        tempPath = [tempPath stringByAppendingPathComponent:[savedDataPath lastPathComponent]];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:tempPath]) {
            [fileManager removeItemAtPath:tempPath error:error];
        }

        if (! [fileManager copyItemAtPath:savedDataPath toPath:tempPath error:error]) {
            return nil;
        }

        return tempPath;
    }
}

- (void)changePassphrase:(NSString *)passphrase
{}

#pragma mark -  OCTSubmanagerDataSource

- (OCTTox *)managerGetTox
{
    return self.tox;
}

- (BOOL)managerIsToxConnected
{
    return (self.user.connectionStatus != OCTToxConnectionStatusNone);
}

- (void)managerSaveTox
{
    return [self saveTox];
}

- (OCTRealmManager *)managerGetRealmManager
{
    return self.realmManager;
}

- (id<OCTFileStorageProtocol>)managerGetFileStorage
{
    return self.configuration.fileStorage;
}

- (NSNotificationCenter *)managerGetNotificationCenter
{
    return self.notificationCenter;
}

#pragma mark -  Private

- (void)validateConfiguration:(OCTManagerConfiguration *)configuration
{
    NSParameterAssert(configuration.fileStorage);
    NSParameterAssert(configuration.fileStorage.pathForDownloadedFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForUploadedFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForTemporaryFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForAvatarsDirectory);

    NSParameterAssert(configuration.options);
}

- (void)createNotificationCenter
{
    _notificationCenter = [[NSNotificationCenter alloc] init];
}

- (void)importToxSaveIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (_configuration.importToxSaveFromPath && [fileManager fileExistsAtPath:_configuration.importToxSaveFromPath]) {
        [fileManager moveItemAtPath:_configuration.importToxSaveFromPath
                             toPath:_configuration.fileStorage.pathForToxSaveFile error:nil];
    }
}

- (NSData *)getSavedData
{
    NSString *savedDataPath = _configuration.fileStorage.pathForToxSaveFile;

    return [[NSFileManager defaultManager] fileExistsAtPath:savedDataPath] ?
           [NSData dataWithContentsOfFile : savedDataPath] :
           nil;
}

- (BOOL)createToxWithSavedData:(NSData *)savedData error:(NSError **)error
{
    _tox = [[OCTTox alloc] initWithOptions:_configuration.options savedData:savedData error:error];
    _toxSaveFileLock = [NSObject new];

    if (! _tox) {
        return NO;
    }

    _tox.delegate = self;
    [_tox start];

    if (! savedData) {
        // Tox was created for the first time, save it.
        [self saveTox];
    }

    return YES;
}

- (void)createRealmManager
{
    _realmManager = [[OCTRealmManager alloc] initWithDatabasePath:_configuration.fileStorage.pathForDatabase];
}

- (void)createSubmanagers
{
    _avatars = [self createSubmanagerWithClass:[OCTSubmanagerAvatars class]];
    _bootstrap = [self createSubmanagerWithClass:[OCTSubmanagerBootstrap class]];
    _chats = [self createSubmanagerWithClass:[OCTSubmanagerChats class]];
    _dns = [self createSubmanagerWithClass:[OCTSubmanagerDNS class]];
    _files = [self createSubmanagerWithClass:[OCTSubmanagerFiles class]];
    _friends = [self createSubmanagerWithClass:[OCTSubmanagerFriends class]];
    _objects = [self createSubmanagerWithClass:[OCTSubmanagerObjects class]];
    _user = [self createSubmanagerWithClass:[OCTSubmanagerUser class]];
}

- (id<OCTSubmanagerProtocol>)createSubmanagerWithClass:(Class)class
{
    id<OCTSubmanagerProtocol> submanager = [class new];
    submanager.dataSource = self;

    if ([submanager respondsToSelector:@selector(configure)]) {
        [submanager configure];
    }

    return submanager;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    id submanager = [self forwardingTargetForSelector:aSelector];

    if (submanager) {
        return YES;
    }

    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    struct objc_method_description description = protocol_getMethodDescription(@protocol(OCTToxDelegate), aSelector, NO, YES);

    if (description.name == NULL) {
        // We forward methods only from OCTToxDelegate protocol.
        return nil;
    }

    NSArray *submanagers = @[
        self.avatars,
        self.bootstrap,
        self.chats,
        self.dns,
        self.files,
        self.friends,
        self.objects,
        self.user,
    ];

    for (id delegate in submanagers) {
        if ([delegate respondsToSelector:aSelector]) {
            return delegate;
        }
    }

    return nil;
}

- (void)saveTox
{
    @synchronized(self.toxSaveFileLock) {
        NSString *savedDataPath = self.configuration.fileStorage.pathForToxSaveFile;

        NSData *data = [self.tox save];

        NSError *error;

        if (! [data writeToFile:savedDataPath options:NSDataWritingAtomic error:&error]) {
            NSDictionary *userInfo = nil;

            if (error) {
                userInfo = @{ @"NSError" : error };
            }

            @throw [NSException exceptionWithName:@"saveToxException" reason:error.debugDescription userInfo:userInfo];
        }
    }
}

#pragma mark -  Deprecated

- (instancetype)initWithConfiguration:(OCTManagerConfiguration *)configuration
                  loadToxSaveFilePath:(NSString *)toxSaveFilePath
                                error:(NSError **)error
{
    configuration.importToxSaveFromPath = toxSaveFilePath;
    return [self initWithConfiguration:configuration error:error];
}

- (instancetype)initWithConfiguration:(OCTManagerConfiguration *)configuration
{
    return [self initWithConfiguration:configuration error:nil];
}

- (instancetype)initWithConfiguration:(OCTManagerConfiguration *)configuration
                  loadToxSaveFilePath:(NSString *)toxSaveFilePath
{
    return [self initWithConfiguration:configuration loadToxSaveFilePath:toxSaveFilePath error:nil];
}

- (BOOL)bootstrapFromHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error
{
    return [self.tox bootstrapFromHost:host port:port publicKey:publicKey error:error];
}

- (BOOL)addTCPRelayWithHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error
{
    return [self.tox addTCPRelayWithHost:host port:port publicKey:publicKey error:error];
}

@end
