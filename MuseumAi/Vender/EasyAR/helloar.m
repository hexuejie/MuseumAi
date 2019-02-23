//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "helloar.h"

#import "VideoRenderer.h"
#import "ARVideo.h"

#import <easyar/types.oc.h>
#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>
#import <AVFoundation/AVFoundation.h>

#include <OpenGLES/ES2/gl.h>

easyar_CameraDevice * camera = nil;
easyar_CameraFrameStreamer * streamer = nil;
NSMutableArray<easyar_ImageTracker *> * trackers = nil;
easyar_Renderer * videobg_renderer = nil;
NSMutableArray<VideoRenderer *> * video_renderers = nil;
VideoRenderer * current_video_renderer = nil;
int tracked_target = 0;
int active_target = 0;
int vodeoCount = 0;
int videoType = 0;
int camera_filter = 0;  // 摄像机去抖
easyar_Matrix44F *fullSize = nil;
easyar_Vec2F *fullVec = nil;
easyar_ImageTarget *currentTarget = nil;
ARVideo * video = nil;
bool viewport_changed = false;
int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};
double video_size[] = {0.0,0.0};
BOOL isFound;

void loadFromImage(easyar_ImageTracker * tracker, NSString *name, NSString * imagePath, int index)
{
    
//    NSMutableArray *mutAry = [NSMutableArray arrayWithArray:[imagePath componentsSeparatedByString:@"/"]];
//    [mutAry removeLastObject];
//    NSString *newPath = [mutAry componentsJoinedByString:@"/"];
//    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:nil];
//    NSLog(@"ZAC---list:%@",list);
    
    imagePath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),imagePath];
    easyar_ImageTarget * target = [easyar_ImageTarget create];
    NSString *uid = [NSString stringWithFormat:@"%d",index];
    NSString * jstr = [@[@"{\n"
                         " \"images\" :\n"
                         " [\n"
                         " {\n"
                         " \"name\" : \"", name, @"\",\n"
                         " \"image\" : \"", imagePath, @"\",\n"
                         " \"uid\" : \"", uid, @"\"\n"
                         " }\n"
                         " ]\n"
                         "}"] componentsJoinedByString:@""];
    
    bool result = [target setup:jstr storageType:(easyar_StorageType_Assets | easyar_StorageType_Json) name:@""];
    NSLog(@"ZAC---%@",result?@"true":@"false");
    [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
        NSLog(@"ZAC---load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
    }];
}

void loadAllFromJsonFile(easyar_ImageTracker * tracker, NSString * path) {

    for (easyar_ImageTarget * target in [easyar_ImageTarget setupAll:path storageType:(easyar_StorageType_Assets | easyar_StorageType_Json)]) {
        [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
            NSLog(@"ZAC---load target (%d): %@ (%d)", status, [target name], [target runtimeID]);
        }];
    }
}

BOOL initialize(NSArray *ary)
{
    vodeoCount = ary.count;
    camera = [easyar_CameraDevice create];
    streamer = [easyar_CameraFrameStreamer create];
    [streamer attachCamera:camera];

    bool status = true;
    status &= [camera open:easyar_CameraDeviceType_Default];
    [camera setSize:[easyar_Vec2I create:@[@1280, @720]]];

    if (!status) { return status; }
    easyar_ImageTracker * tracker = [easyar_ImageTracker create];
    [tracker attachStreamer:streamer];
//    loadAllFromJsonFile(tracker, path);
    for (int i=0; i<ary.count; i++) {
        NSDictionary *dic = ary[i];
        loadFromImage(tracker, dic[@"name"], dic[@"image"], i);
    }
    
    trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    [trackers addObject:tracker];

    return status;
}

void finalize()
{
    video = nil;
    fullSize = nil;
    currentTarget = nil;
    tracked_target = 0;
    active_target = 0;

    [trackers removeAllObjects];
    [video_renderers removeAllObjects];
    current_video_renderer = nil;
    isFound = NO;
    videobg_renderer = nil;
    streamer = nil;
    camera = nil;
}

BOOL start()
{
    bool status = true;
    status &= (camera != nil) && [camera start];
    status &= (streamer != nil) && [streamer start];
    [camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker start];
    }
    return status;
}

BOOL stop()
{
    bool status = true;
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker stop];
    }
    status &= (streamer != nil) && [streamer stop];
    status &= (camera != nil) && [camera stop];
    return status;
}

void initGL()
{
    if (active_target != 0) {
        [video onLost];
        video = nil;
        tracked_target = 0;
        active_target = 0;
    }
    videobg_renderer = nil;
    videobg_renderer = [easyar_Renderer create];
    video_renderers = [[NSMutableArray<VideoRenderer *> alloc] init];
    NSLog(@"%ld",vodeoCount);
    for (int k = 0; k < vodeoCount; k += 1) {
        VideoRenderer * video_renderer = [[VideoRenderer alloc] init];
        [video_renderer init_];
        [video_renderers addObject:video_renderer];
    }
    current_video_renderer = nil;
    isFound = NO;
}

void resizeGL(int width, int height)
{
    view_size[0] = width;
    view_size[1] = height;
    viewport_changed = true;
}

void updateViewport()
{
    easyar_CameraCalibration * calib = camera != nil ? [camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        viewport_changed = true;
    }
    if (viewport_changed) {
        int size[] = {1, 1};
        if (camera && [camera isOpened]) {
            size[0] = [[[camera size].data objectAtIndex:0] intValue];
            size[1] = [[[camera size].data objectAtIndex:1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float)view_size[0] / (float)size[0], (float)view_size[1] / (float)size[1]);
        NSLog(@"scaleRatio:%.2f",scaleRatio);
        int viewport_size[] = {(int)roundf(size[0] * scaleRatio), (int)roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));
        
        if (camera && [camera isOpened])
            viewport_changed = false;
    }
}

void render()
{
    
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I * oc_default_viewport = [easyar_Vec4I create:@[[NSNumber numberWithInt:default_viewport[0]], [NSNumber numberWithInt:default_viewport[1]], [NSNumber numberWithInt:default_viewport[2]], [NSNumber numberWithInt:default_viewport[3]]]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }

    if (streamer == nil) { return; }
    easyar_Frame * frame = [streamer peek];
    updateViewport();
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (videobg_renderer != nil) {
        [videobg_renderer render:frame viewport:[easyar_Vec4I create:@[[NSNumber numberWithInt:viewport[0]], [NSNumber numberWithInt:viewport[1]], [NSNumber numberWithInt:viewport[2]], [NSNumber numberWithInt:viewport[3]]]]];
    }

    NSArray<easyar_TargetInstance *> * targetInstances = [frame targetInstances];
    
    if ([targetInstances count] > 0) {
        camera_filter = 0;
        easyar_TargetInstance * targetInstance = [targetInstances firstObject];
        easyar_Target * target = [targetInstance target];
        int status = [targetInstance status];
        if (status == easyar_TargetStatus_Tracked) {
            
            int runtimeID = [target runtimeID];
            if (active_target != 0 &&
                active_target != runtimeID &&
                !isFound) {
                [video onLost];
                video = nil;
                tracked_target = 0;
                active_target = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:kARLoseTargetNotification object:@""];
                return;
            }
            if (tracked_target == 0) {
                
                if (video == nil &&
                    [video_renderers count] > 0) {
                    
                    NSString * target_name = [target name];
                    NSInteger index = [[target uid]integerValue];
                    NSArray *targetAry = [target_name componentsSeparatedByString:@"_"];
                    if (targetAry.count != 3) {
                        return;
                    }
                    NSString *hallId = [targetAry firstObject];
                    NSString *exhibitId = [targetAry objectAtIndex:1];
                    NSInteger type = [[targetAry lastObject] integerValue];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kARFoundTargetNotification object:target_name];
                    
                    if (type == 0) {
                        return;
                    }
                    videoType = (int)type;
                    
                    if ([video_renderers[index] texid] != 0 &&
                        current_video_renderer == nil) {
                        
                        video = [[ARVideo alloc] init];
                        NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/%@/%@.mp4",NSHomeDirectory(),hallId,exhibitId];
                        
                        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
                        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                        if([tracks count] > 0) {
                            AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                            video_size[0] = videoTrack.naturalSize.width/2.0f;
                            video_size[1] = videoTrack.naturalSize.height;
                            video_size[0] /= 215.0f;
                            video_size[1] /= 215.0f;
                        }
                        [video openTransparentVideoFile:path texid:[video_renderers[index] texid]];
                        current_video_renderer = video_renderers[index];
                    }
                }
                if (video != nil && !isFound) {
                    isFound = YES;
                    [video onFound];
                    tracked_target = runtimeID;
                    active_target = runtimeID;
                }
                
            }
            easyar_ImageTarget * imagetarget = [target isKindOfClass:[easyar_ImageTarget class]] ? (easyar_ImageTarget *)target : nil;
            currentTarget = imagetarget;
            if (imagetarget != nil && current_video_renderer != nil) {
                [video update];
                if (fullSize == nil) {
                    NSArray *fullScreenData = @[@0,@(-1),@0,@0.0,
                                                @(-1),@0,@0,@0.0,
                                                @0,@0,@1,@0.0,
                                                @0,@0,@(-1.5),@(1.0)];
                    fullSize = [easyar_Matrix44F create:fullScreenData];
                }
                
                CGFloat scale = video_size[1]/video_size[0];
                NSArray *fullVecData = @[@(1.0),@(scale)];;
//                if (scale > 1) {
//                    fullVecData = @[@(1.0/scale),@(1.0)];
//                } else {
//                    fullVecData = @[@(1.0),@(scale)];
//                }
                fullVec = [easyar_Vec2F create:fullVecData];
                
                if ([video isRenderTextureAvailable]) {
                    if (videoType == 1) {
                        [current_video_renderer render:[camera projectionGL:0.2f farPlane:500.f]
                                            cameraview:[targetInstance poseGL]
                                                  size:[imagetarget size]];
                    }else {
                        [current_video_renderer render:[camera projectionGL:0.2f farPlane:500.f]
                                        cameraview:fullSize
                                              size:fullVec];
                    }
                }
            } else {
                NSLog(@"zac---测试2");
            }
        } else {
            if (videoType != 1 && current_video_renderer != nil) {  // 解决视频突然消失BUG
                [video update];
                if ([video isRenderTextureAvailable]) {
                    [current_video_renderer render:[camera projectionGL:0.2f farPlane:500.f]
                                        cameraview:fullSize
                                              size:fullVec];
                }
            }
        }
    } else {
        if (tracked_target != 0) {
            if (videoType == 1) { // 跟随
                NSLog(@"Lost---跟随");
                if (camera_filter < 50) {
                    camera_filter ++;   // 去抖
                    return;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kARLoseTargetNotification object:@""];
                [video onLost];
                tracked_target = 0;
            } else {
                NSLog(@"Lost---弹出");
                [video update];
                [current_video_renderer render:[camera projectionGL:0.2f farPlane:500.f]
                                    cameraview:fullSize
                                          size:fullVec];
            }
        }
    }
}
