/*===============================================================================
 Copyright (c) 2016-2018 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import "VideoPlaybackEAGLView.h"

#ifndef MUSimulatorTest
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/ImageTarget.h>
#import <Accelerate/Accelerate.h>

#import "MUVuforiaViewController.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "SampleMath.h"
#import "Quad.h"

//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---
    
    // Texture filenames (an Object3D object is created for each texture)
    const char* textureFilenames[kNumAugmentationTextures] = {
        "icon_play.png",
        "icon_loading.png",
        "icon_error.png",
        "VuforiaSizzleReel_1.png",
        "VuforiaSizzleReel_2.png"
    };
    
    enum tagObjectIndex {
        OBJECT_PLAY_ICON,
        OBJECT_BUSY_ICON,
        OBJECT_ERROR_ICON,
        OBJECT_KEYFRAME_1,
        OBJECT_KEYFRAME_2,
    };
    
    const NSTimeInterval TRACKING_LOST_TIMEOUT = 2.0f;
    
    // Playback icon scale factors
    const float SCALE_ICON = 2.0f;
    
    // Video quad texture coordinates
    const GLfloat videoQuadTextureCoords[] = {
        0.0, 1.0,
        0.5, 1.0,
        0.5, 0.0,
        0.0, 0.0,
    };
    
    struct tagVideoData {
        // Needed to calculate whether a screen tap is inside the target
        Vuforia::Matrix44F modelViewMatrix;
        
        // Trackable dimensions
        Vuforia::Vec2F targetPositiveDimensions;
        
        // Currently active flag
        BOOL isActive;
    } videoData[kMaxTargetsNum];
    
    //    int touchedTarget = 0;
}


@interface VideoPlaybackEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end


@implementation VideoPlaybackEAGLView
{
    NSString *_vuforiaID;    // 发现的目标
}
@synthesize vapp, vars, isDownLoad;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
                ars:(NSArray<MUARModel *> *)ars
 rootViewController:(UIViewController *)rootViewController
         appSession:(SampleApplicationSession *)app {
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        vars = ars;
        
        vapp = app;
        
        videoPlaybackViewController = rootViewController;
        
        // Enable retina mode if available on this device
        [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        
        // Load the augmentation textures
        for (int i = 0; i < kNumAugmentationTextures; ++i)
        {
            augmentationTexture[i] = [[Texture alloc] initWithImageFile:[NSString stringWithCString:textureFilenames[i] encoding:NSASCIIStringEncoding]];
        }
        
        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        sampleAppRenderer = [[SampleAppRenderer alloc] initWithSampleAppRendererControl:self nearPlane:0.01 farPlane:5];
        
        // Generate the OpenGL ES texture and upload the texture data for use
        // when rendering the augmentation
        for (int i = 0; i < kNumAugmentationTextures; ++i)
        {
            GLuint textureID;
            glGenTextures(1, &textureID);
            [augmentationTexture[i] setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture[i] width], [augmentationTexture[i] height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture[i] pngData]);
            
            // Set appropriate texture parameters (for NPOT textures)
            if (OBJECT_KEYFRAME_1 <= i)
            {
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
        }
        
        [sampleAppRenderer initRendering];
        [self initShaders];
    }
    
    return self;
}

- (void) willPlayVideoFullScreen:(BOOL) fullScreen
{
    playVideoFullScreen = fullScreen;
}

- (void)prepare {
    
    for (int i = 0; i < self.vars.count; ++i)
    {
        videoPlayerHelper[i] = [[VideoPlayerHelper alloc] initWithRootViewController:videoPlaybackViewController];
        videoData[i].targetPositiveDimensions.data[0] = 0.0f;
        videoData[i].targetPositiveDimensions.data[1] = 0.0f;
    }
    
    for (int i = 0; i < self.vars.count; ++i)
    {
        videoPlaybackTime[i] = VIDEO_PLAYBACK_CURRENT_POSITION;
    }
    /*
    for (int i = 0; i < self.vars.count; ++i) {
        VideoPlayerHelper* player = videoPlayerHelper[i];
        if ([MUARUtils isVideoExsitForHall:self.hallID exhibits:self.vars[i]]) {
            NSString* filePath = [MUARUtils getVideoPathWithHallID:self.hallID exhibit:self.vars[i]];
            if (![player load:filePath playImmediately:NO fromPosition:videoPlaybackTime[i]]) {
                NSLog(@"Failed to load media");
            }
        }
    }
    */
}

- (void) dismiss
{
    for (int i = 0; i < self.vars.count; ++i)
    {
        [videoPlayerHelper[i] unload];
        videoPlayerHelper[i] = nil;
    }
}

- (void)dealloc
{
    NSLog(@"playback dealloc");
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    for (int i = 0; i < kNumAugmentationTextures; ++i)
    {
        augmentationTexture[i] = nil;
    }
    
    for (int i = 0; i < self.vars.count; ++i)
    {
        videoPlayerHelper[i] = nil;
    }
}


- (void)finishOpenGLESCommands {
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

//------------------------------------------------------------------------------
#pragma mark - User interaction

- (void) preparePlayers
{
    [self prepare];
}

- (void) dismissPlayers
{
    [self dismiss];
}

// Determine whether a screen tap is inside the target
- (int)tapInsideTargetWithID
{
    Vuforia::Vec3F intersection, lineStart, lineEnd;
    Vuforia::Matrix44F inverseProjMatrix = SampleMath::Matrix44FInverse(tapProjectionMatrix);
    CGRect rect = [self bounds];
    int touchInTarget = -1;
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // The target returns as pose the centre of the trackable.  Thus its
    // dimensions go from -width / 2 to width / 2 and from -height / 2 to
    // height / 2.  The following if statement simply checks that the tap is
    // within this range
    for (int i = 0; i < self.vars.count; ++i)
    {
        SampleMath::projectScreenPointToPlane(inverseProjMatrix,
                                              videoData[i].modelViewMatrix,
                                              rect.size.width,
                                              rect.size.height,
                                              Vuforia::Vec2F(touchLocation_X, touchLocation_Y),
                                              Vuforia::Vec3F(0, 0, 0),
                                              Vuforia::Vec3F(0, 0, 1),
                                              intersection,
                                              lineStart,
                                              lineEnd);
        
        if ((intersection.data[0] >= -videoData[i].targetPositiveDimensions.data[0]) &&
            (intersection.data[0] <= videoData[i].targetPositiveDimensions.data[0]) &&
            (intersection.data[1] >= -videoData[i].targetPositiveDimensions.data[1]) &&
            (intersection.data[1] <= videoData[i].targetPositiveDimensions.data[1]))
        {
            // The tap is only valid if it is inside an active target
            if (videoData[i].isActive)
            {
                touchInTarget = i;
                break;
            }
        }
    }
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    return touchInTarget;
}


- (void) updateRenderingPrimitives
{
    [sampleAppRenderer updateRenderingPrimitives];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia {
    if (!vapp.cameraIsStarted) {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}

- (void)renderFrameWithState:(const Vuforia::State &)state
               projectMatrix:(Vuforia::Matrix44F &)projectionMatrix {
    
    /// FIXME:定时调用
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render the video background
    [sampleAppRenderer renderVideoBackgroundWithState:state];
    
    glEnable(GL_DEPTH_TEST);
    
    // We must detect if background reflection is active and adjust the culling
    // direction.  If the reflection is active, this means the pose matrix has
    // been reflected as well, therefore standard counter clockwise face culling
    // will result in "inside out" models
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // ----- Synchronise data access -----
    [dataLock lock];
    
    // Assume all targets are inactive (used when determining tap locations)
    for (int i = 0; i < self.vars.count; ++i) {
        videoData[i].isActive = NO;
    }
    
    tapProjectionMatrix = projectionMatrix;
    
    // Did we find any trackables this frame?
    const auto& trackableResultList = state.getTrackableResults();
    for (const auto* trackableResult : trackableResultList) {
        if (_vuforiaID.length > 0) {
            break;
        }
        const Vuforia::ImageTarget& imageTarget = (const Vuforia::ImageTarget&) trackableResult->getTrackable();
        
        _vuforiaID = [NSString stringWithCString:imageTarget.getUniqueTargetId() encoding:NSUTF8StringEncoding];
        MUARModel *ar = [MUARUtils exhibitWithImageTargetID:_vuforiaID fromArs:self.vars];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverTargetNotification object:ar];
        NSLog(@"发现目标%@",_vuforiaID);
    }
    if (_vuforiaID.length > 0) {
        [self renderPlayer];
    }
    
    /*
    // 正在播放视频、去掉定时器为空，未发现目标视频
    for (int i = 0; i < self.vars.count; ++i) {
        
        if (nil == trackingLostTimer &&
            NO == videoData[i].isActive &&
            PLAYING == [videoPlayerHelper[i] getStatus]) {
            // 创建去抖定时器 2秒
            [self performSelectorOnMainThread:@selector(createTrackingLostTimer) withObject:nil waitUntilDone:YES];
            break;
        }
    }
     */
    
    [dataLock unlock];
    // ----- End synchronise data access -----
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [self presentFramebuffer];
    
}

/** renderPalyer */
- (void)renderPlayer {
    MUARModel *ar = [MUARUtils exhibitWithImageTargetID:_vuforiaID fromArs:self.vars];
    if (ar == nil) {
        return;
    }
    
    int playerIndex = (int)[self.vars indexOfObject:ar];
    
    if (ar.type == ExhibitsARTypeNone) {
        // 跳入详情页
        if (_vuforiaID &&
            [videoPlaybackViewController isKindOfClass:[MUVuforiaViewController class]]) {
            [self stopPlayAndPushToDetailVC];
        }
        _vuforiaID = nil;
    } else if([MUARUtils isVideoExsitForHall:self.hallID exhibits:ar]) {
        NSInteger i = [self.vars indexOfObject:ar];
        VideoPlayerHelper* player = videoPlayerHelper[i];
        if ([player isLoad]) {
            [self playVideosWithIndex:playerIndex];
        } else {
            NSString* filePath = [MUARUtils getVideoPathWithHallID:self.hallID exhibit:self.vars[i]];
            if ([player load:filePath playImmediately:NO fromPosition:videoPlaybackTime[i]]) {
                [self playVideosWithIndex:playerIndex];
            }
        }
    } else if(!isDownLoad) {
        isDownLoad = YES;
        UIViewController *vc = videoPlaybackViewController;
        [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
        __weak typeof(self) weakSelf = self;
        VideoPlayerHelper *player = videoPlayerHelper[playerIndex];
        [MUARUtils downLoadFile:ar.videoUrl name:[NSString stringWithFormat:@"%@.mp4",ar.exhibitsId] completeHandler:^(NSData * _Nonnull fileData, NSString * _Nonnull fileName, NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:vc.view animated:YES];
            if (!error) {
                [MUARUtils writeToFile:fileData fileName:fileName type:MUWriteFileTypeVideo hallID:weakSelf.hallID];
                weakSelf.isDownLoad = NO;
                if ([MUARUtils isVideoExsitForHall:weakSelf.hallID exhibits:weakSelf.vars[playerIndex]]) {
                    NSString* filePath = [MUARUtils getVideoPathWithHallID:self.hallID exhibit:self.vars[playerIndex]];
                    if ([player load:filePath playImmediately:NO fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION]) {
                        
                        [self playVideosWithIndex:playerIndex];
                        
                    }
                }
            }
        }];
    }
}

- (void)playVideosWithIndex:(NSInteger)playerIndex {
    
    NSLog(@"weizh 跟随播放");
    
    // 激活该视频
    videoData[playerIndex].isActive = YES;
    
    float w = videoPlayerHelper[playerIndex].getVideoWidth/2.0f;
    float h = videoPlayerHelper[playerIndex].getVideoHeight * 1.0f;
    float temp[2];
    temp[0] = 1.0f;
    temp[1] = (SCREEN_WIDTH*h/w)/SCREEN_HEIGHT;
    
    // 计算目标大小
    if (videoData[playerIndex].targetPositiveDimensions.data[0] == 0.0f ||
        videoData[playerIndex].targetPositiveDimensions.data[1] == 0.0f) {
        
        videoData[playerIndex].targetPositiveDimensions.data[0] = temp[0];
        videoData[playerIndex].targetPositiveDimensions.data[1] = temp[1];
        
    }
    
    // This matrix is used to calculate the location of the screen tap
    const Vuforia::Matrix44F mMartrix44 = Vuforia::Matrix44F {
            {1.0f,0.0f,0.0f,0.0f,
            0.0f,1.0f,0.0f,0.0f,
            0.0f,0.0f,1.0f,0.0f,
            0.0f,0.0f,0.0f,1.0f}
    };
    
    Vuforia::Matrix44F projectionMatrix = mMartrix44;
    videoData[playerIndex].modelViewMatrix = mMartrix44;
    
    float aspectRatio;
    const GLvoid* texCoords;
    GLuint frameTextureID = 0;
    BOOL displayVideoFrame = YES;
    
    // Retain value between calls
    static GLuint videoTextureID[kMaxTargetsNum] = {0};
    
    MEDIA_STATE currentStatus = [videoPlayerHelper[playerIndex] getStatus];
    
    if (currentStatus == PLAYING) {
        /*
        // If the tracking lost timer is scheduled, terminate it
        if (trackingLostTimer != nil) {
            // Timer termination must occur on the same thread on which
            // it was installed
            [self performSelectorOnMainThread:@selector(terminateTrackingLostTimer)
                                   withObject:nil
                                waitUntilDone:YES];
        }
         */
        
        // Upload the decoded video data for the latest frame to OpenGL
        // and obtain the video texture ID
        GLuint videoTexID = [videoPlayerHelper[playerIndex] updateVideoData];
        
        if (videoTextureID[playerIndex] == 0) {
            videoTextureID[playerIndex] = videoTexID;
        }
        
        if (videoTextureID[playerIndex] == 0) {
            // No video texture available, display keyframe
            displayVideoFrame = NO;
        } else {
            // Display the texture most recently returned from the call
            // to [videoPlayerHelper updateVideoData]
            frameTextureID = videoTextureID[playerIndex];
        }
    } else {
        videoTextureID[playerIndex] = 0;
        displayVideoFrame = NO;
    }
    
    
    if (displayVideoFrame) {
        // ---- Display the video frame -----
        aspectRatio = (float)[videoPlayerHelper[playerIndex] getVideoHeight] / (float)[videoPlayerHelper[playerIndex] getVideoWidth];
        texCoords = videoQuadTextureCoords;
    } else {
        // ----- Display the keyframe -----
        Texture* t = augmentationTexture[OBJECT_KEYFRAME_1];
        frameTextureID = [t textureID];
        aspectRatio = (float)[t height] / (float)[t width];
        texCoords = quadTexCoords;
    }
    
    // If the current status is valid (not NOT_READY or ERROR), render the
    // video quad with the texture we've just selected
    if (currentStatus != NOT_READY) {
        // Convert trackable pose to matrix for use with OpenGL
        Vuforia::Matrix44F modelViewMatrixVideo = mMartrix44;
        // Vuforia::Tool::convertPose2GLMatrix(trackablePose);
        Vuforia::Matrix44F modelViewProjectionVideo;
        
        SampleApplicationUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[0],
                                                videoData[playerIndex].targetPositiveDimensions.data[0] * aspectRatio,
                                                videoData[playerIndex].targetPositiveDimensions.data[0],
                                                &modelViewMatrixVideo.data[0]);
        
        SampleApplicationUtils::multiplyMatrix(projectionMatrix.data,
                                               &modelViewMatrixVideo.data[0] ,
                                               &modelViewProjectionVideo.data[0]);
        
        glUseProgram(shaderProgramID);
        
        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
        glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        // Blend the video over the background
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, frameTextureID);
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionVideo.data[0]);
        glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
        glDrawElements(GL_TRIANGLES, kNumQuadIndices, GL_UNSIGNED_SHORT, quadIndices);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        glUseProgram(0);
    }
    
    // If the current status is not PLAYING, render an icon
    if (currentStatus != PLAYING) {
        
        GLuint iconTextureID = 0;
        
        switch (currentStatus)
        {
            case READY:
            case PAUSED:
            case STOPPED:
            {
                // ----- Display play icon -----
                [videoPlayerHelper[playerIndex] play:playVideoFullScreen fromPosition:VIDEO_PLAYBACK_CURRENT_POSITION];
                iconTextureID = [augmentationTexture[OBJECT_PLAY_ICON] textureID];
                break;
            }
            case REACHED_END: {
                NSLog(@"weizh 跟随视频播放完毕");
                if (_vuforiaID &&
                    [videoPlaybackViewController isKindOfClass:[MUVuforiaViewController class]]) {
                    [self stopPlayAndPushToDetailVC];
                }
                break;
            }
            case ERROR: {
                // ----- Display error icon -----
                NSLog(@"weizh 跟随视频播放错误");
                if (_vuforiaID &&
                    [videoPlaybackViewController isKindOfClass:[MUVuforiaViewController class]]) {
                    [self stopPlayAndPushToDetailVC];
                }
                iconTextureID = [augmentationTexture[OBJECT_ERROR_ICON] textureID];
                break;
            }
            default: {
                // ----- Display busy icon -----
                iconTextureID = [augmentationTexture[OBJECT_BUSY_ICON] textureID];
                break;
            }
        }
        
        // Convert trackable pose to matrix for use with OpenGL
        Vuforia::Matrix44F modelViewMatrixButton = mMartrix44;
        // Vuforia::Tool::convertPose2GLMatrix(trackablePose);
        Vuforia::Matrix44F modelViewProjectionButton;
        
        SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, 0.01f, &modelViewMatrixButton.data[0]);
        
        SampleApplicationUtils::scalePoseMatrix(videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                videoData[playerIndex].targetPositiveDimensions.data[1] / SCALE_ICON,
                                                &modelViewMatrixButton.data[0]);
        
        SampleApplicationUtils::multiplyMatrix(projectionMatrix.data,
                                               &modelViewMatrixButton.data[0] ,
                                               &modelViewProjectionButton.data[0]);
        
        glDepthFunc(GL_LEQUAL);
        
        glUseProgram(shaderProgramID);
        
        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, quadVertices);
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, quadNormals);
        glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, quadTexCoords);
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        // Blend the icon over the background
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, iconTextureID);
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjectionButton.data[0] );
        glDrawElements(GL_TRIANGLES, kNumQuadIndices, GL_UNSIGNED_SHORT, quadIndices);
        
        glDisable(GL_BLEND);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        glUseProgram(0);
        
        glDepthFunc(GL_LESS);
    }
    
    SampleApplicationUtils::checkGlError("VideoPlayback renderFrameVuforia");
}

/** 停止播放并跳转到详情页 */
- (void)stopPlayAndPushToDetailVC {
    
    MUVuforiaViewController *vc = (MUVuforiaViewController *)videoPlaybackViewController;
    MUARModel *ar = [MUARUtils exhibitWithImageTargetID:_vuforiaID fromArs:self.vars];
    
    isDownLoad = NO;
    _vuforiaID = nil;
    [self stopPlay];
    [vc toExhibitsDetail:ar.exhibitsId];
}

/*
- (void)createTrackingLostTimer
{
    trackingLostTimer = [NSTimer scheduledTimerWithTimeInterval:TRACKING_LOST_TIMEOUT target:self selector:@selector(trackingLostTimerFired:) userInfo:nil repeats:NO];
}


// Terminate the tracking lost timer
- (void)terminateTrackingLostTimer
{
    [trackingLostTimer invalidate];
    trackingLostTimer = nil;
}


// Tracking lost timer fired, pause video playback
- (void)trackingLostTimerFired:(NSTimer*)timer
{
    /// FIXME: 失去目标
    NSLog(@"weizh 失去目标");
    for (int i = 0; i < self.vars.count; ++i)
    {
        [videoPlayerHelper[i] pause];
    }
    trackingLostTimer = nil;
}
 */

- (void)stopPlay {
    _vuforiaID = nil;
    for (int i = 0; i < self.vars.count; ++i) {
        [videoPlayerHelper[i] pause];
    }
}


- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                   fragmentShaderFileName:@"Simple.fragsh"];
    
    if (shaderProgramID > 0)
    {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else
    {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context)
    {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext])
    {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer)
    {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}

#else

@implementation VideoPlaybackEAGLView

#endif

@end

