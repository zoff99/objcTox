//
//  OCTSubmanagerCalls.h
//  objcTox
//
//  Created by Chuong Vu on 5/8/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTView.h"
#import "OCTChat.h"
#import "OCTToxAVConstants.h"
#import "OCTSubmanagerCallsDelegate.h"

@class OCTSubmanagerCalls;
@class OCTToxAV;
@class OCTCall;

@interface OCTSubmanagerCalls : NSObject

@property (nullable, weak, nonatomic) id<OCTSubmanagerCallDelegate> delegate;

/**
 * Set the property to YES to enable the microphone, otherwise NO.
 * Default value is YES at the start of every call;
 **/
@property (nonatomic, assign) BOOL enableMicrophone;

/**
 * This must be called once after initialization.
 * @param error Pointer to an error when setting up.
 * @return YES on success, otherwise NO.
 */
- (BOOL)setupWithError:(NSError *__nullable *__nullable)error;

/**
 * Use a different camera for input.
 * @param front YES to use the front camera, NO to use the
 * rear camera. Front camera is used by default.
 * @error Pointer to error object.
 * @return YES on success, otherwise NO.
 */
- (BOOL)switchToCameraFront:(BOOL)front error:(NSError *__nullable *__nullable)error;

/**
 * This class is responsible for telling the end-user what calls we have available.
 * We can also initialize a call session from here.
 * @param chat The chat for which we would like to initiate a call.
 * @param enableAudio YES for Audio, otherwise NO.
 * @param enableVideo YES for Video, otherwise NO.
 * @param error Pointer to an error when attempting to answer a call
 * @return OCTCall session
 */
- (nullable OCTCall *)callToChat:(nonnull OCTChat *)chat
                     enableAudio:(BOOL)enableAudio
                     enableVideo:(BOOL)enableVideo
                           error:(NSError *__nullable *__nullable)error;

/**
 * Enable video calling for an active call.
 * Use this when you started a call without video in the first place.
 * @param enable YES to enable video, NO to stop video sending.
 * @param call Call to enable video for.
 * @param error Pointer to an error object.
 * @return YES on success, otherwise NO.
 */
- (BOOL)enableVideoSending:(BOOL)enable
                   forCall:(nonnull OCTCall *)call
                     error:(NSError *__nullable *__nullable)error;

/**
 * Answer a call
 * @param call The call session we would like to answer
 * @param enableAudio YES for Audio, otherwise NO.
 * @param enableVideo YES for Video, otherwise NO.
 * @param error Pointer to an error when attempting to answer a call
 * @return YES if we were able to succesfully answer the call, otherwise NO.
 */
- (BOOL)answerCall:(nonnull OCTCall *)call
       enableAudio:(BOOL)enableAudio
       enableVideo:(BOOL)enableVideo
             error:(NSError *__nullable *__nullable)error;

/**
 * Send the audio to the speaker
 * @param speaker YES to send audio to speaker, NO to reset to default.
 * @param error Pointer to error object.
 * @return YES if successful, otherwise NO.
 */
- (BOOL)routeAudioToSpeaker:(BOOL)speaker
                      error:(NSError *__nullable *__nullable)error;

/**
 * Send call control to call.
 * @param control The control to send to call.
 * @param call The appopriate call to send to.
 * @param error Pointer to error object if there's an issue muting the call.
 * @return YES if succesful, NO otherwise.
 */
- (BOOL)sendCallControl:(OCTToxAVCallControl)control
                 toCall:(nonnull OCTCall *)call
                  error:(NSError *__nullable *__nullable)error;

/**
 * The OCTView that will have the video feed.
 */
- (nullable OCTView *)videoFeed;

/**
 * The preview video of the user.
 * You must be in a video call for this to show. Otherwise the layer will
 * just be black.
 * @param completionBlock Block responsible for using the layer. This
 * must not be nil.
 */
- (void)getVideoCallPreview:(void (^__nonnull)( CALayer *__nullable layer))completionBlock;

/**
 * Set the Audio bit rate.
 * @param bitrate The bitrate to change to.
 * @param call The Call to set the bitrate for.
 * @param error Pointer to error object if there's an issue setting the bitrate.
 */
- (BOOL)setAudioBitrate:(int)bitrate forCall:(nonnull OCTCall *)call error:(NSError *__nullable *__nullable)error;

@end
