
//
//  FaceInsertView.m
//  CaptureAcesso
//
//  Created by Matheus  domingos on 27/03/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "FaceInsertView.h"
#import "CameraBio.h"

@interface FaceInsertView ()

@end

@implementation FaceInsertView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [cameraFrame setCountdownValue:3];
    [cameraFrame setOffsetTopPercent:30.0f];
    [cameraFrame setSizePercentBetweenTopAndBottom:20.0f];
    
    isSelfie = YES;
    [self setupCamera:isSelfie];
    [self startCamera];
    
    FIRVisionFaceDetectorOptions *options = [[FIRVisionFaceDetectorOptions alloc] init];
    options.minFaceSize = 0.1;
    options.performanceMode = FIRVisionFaceDetectorPerformanceModeAccurate;
    options.landmarkMode = FIRVisionFaceDetectorLandmarkModeAll;
    options.trackingEnabled = @YES;
    
    FIRVision *vision = [FIRVision vision];
    FIRVisionFaceDetector *faceDetector = [vision faceDetectorWithOptions:options];
    
    self.faceDetector = faceDetector;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
            [cameraFrame showRed];
            break;
        case UIDeviceOrientationLandscapeRight:
            [cameraFrame showRed];
            break;
        default:
            break;
    };
}

- (void) setupCamera:(BOOL) isSelfie {
    [super setupCamera:isSelfie];
    
    cameraFrame = [[CameraFrame alloc] initWithView:self button:self.btTakePic autoCapture:self.isAutoCapture contagem:self.isCountdown view:self.view];
    
}


- (FIRVisionDetectorImageOrientation)
imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
cameraPosition:(AVCaptureDevicePosition)cameraPosition {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationLeftTop;
            } else {
                return FIRVisionDetectorImageOrientationRightTop;
            }
        case UIDeviceOrientationLandscapeLeft:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationBottomLeft;
            } else {
                return FIRVisionDetectorImageOrientationTopLeft;
            }
        case UIDeviceOrientationPortraitUpsideDown:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationRightBottom;
            } else {
                return FIRVisionDetectorImageOrientationLeftBottom;
            }
        case UIDeviceOrientationLandscapeRight:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationTopRight;
            } else {
                return FIRVisionDetectorImageOrientationBottomRight;
            }
        default:
            return FIRVisionDetectorImageOrientationTopLeft;
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                 sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
    AVCaptureDevicePosition cameraPosition = AVCaptureDevicePositionFront;
    metadata.orientation = [self imageOrientationFromDeviceOrientation:deviceOrientation cameraPosition:cameraPosition];
    
    FIRVisionImage *image = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
    image.metadata = metadata;
    
    [self.faceDetector processImage:image completion:^(NSArray<FIRVisionFace *> * _Nullable faces, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error %@", error);
            return;
        } else if (faces != nil) {
            
            countNoFace = 0;
            
            if([faces count] == 0) {
                countNoFace++;
                if(countNoFace >= 20)
                    [cameraFrame showGray];
                return;
            }
            
            FIRVisionFace *face = faces[0];
            
            CGRect frame = face.frame;
            
            CGFloat faceHeadEulerAngleY;
            if (face.hasHeadEulerAngleY) {
                faceHeadEulerAngleY = face.headEulerAngleY;  // Head is rotated to the right rotY degrees
            }
            
            CGFloat faceHeadEulerAngleZ;
            if (face.hasHeadEulerAngleZ) {
                faceHeadEulerAngleZ = face.headEulerAngleZ;  // Head is tilted sideways rotZ degrees
            }
            
            FIRVisionPoint *leftEyePosition;
            FIRVisionFaceLandmark *leftEye = [face landmarkOfType:FIRFaceLandmarkTypeLeftEye];
            if (leftEye != nil) {
                leftEyePosition = leftEye.position;
            }
            
            FIRVisionPoint *rightEyePosition;
            FIRVisionFaceLandmark *rightEye = [face landmarkOfType:FIRFaceLandmarkTypeRightEye];
            if (rightEye != nil) {
                rightEyePosition = rightEye.position;
            }
            
            FIRVisionPoint *leftEarPosition;
            FIRVisionFaceLandmark *leftEar = [face landmarkOfType:FIRFaceLandmarkTypeLeftEar];
            if (leftEar != nil) {
                leftEarPosition = leftEar.position;
            }
            
            FIRVisionPoint *rightEarPosition;
            FIRVisionFaceLandmark *rightEar = [face landmarkOfType:FIRFaceLandmarkTypeRightEar];
            if (rightEar != nil) {
                rightEarPosition = rightEar.position;
            }
            
            FIRVisionPoint *noseBasePosition;
            FIRVisionFaceLandmark *noseBase = [face landmarkOfType:FIRFaceLandmarkTypeNoseBase];
            if (noseBase != nil) {
                noseBasePosition = noseBase.position;
            }
            
            if(leftEye != nil && rightEye != nil && leftEar != nil && rightEar != nil && noseBasePosition != nil) {
                
                countNoNose = 0;
                
                CGFloat scale = 2;
                
                // Olhos
                CGFloat X_LEFT_EYE_POINT = SCREEN_WIDTH - (leftEyePosition.x.doubleValue/scale);
                CGFloat Y_LEFT_EYE_POINT = leftEyePosition.y.doubleValue/scale;
                
                CGFloat X_RIGHT_EYE_POINT = SCREEN_WIDTH - (rightEyePosition.x.doubleValue/scale);
                CGFloat Y_RIGHT_EYE_POINT = rightEyePosition.y.doubleValue/scale;
                
                // Orelhas
                CGFloat X_LEFT_EAR_POINT = SCREEN_WIDTH - (leftEarPosition.x.doubleValue/scale);
                CGFloat Y_LEFT_EAR_POINT = leftEarPosition.y.doubleValue/scale;
                
                CGFloat X_RIGHT_EAR_POINT = SCREEN_WIDTH - (rightEarPosition.x.doubleValue/scale);
                CGFloat Y_RIGHT_EAR_POINT = rightEarPosition.y.doubleValue/scale;
                
                // Nariz
                CGFloat X_NOSEBASEPOSITION_POINT = SCREEN_WIDTH - (noseBasePosition.x.doubleValue/scale);
                CGFloat Y_NOSEBASEPOSITION_POINT = noseBasePosition.y.doubleValue/scale;
                
                //Angulo
                CGFloat ANGLE_HORIZONTAL = faceHeadEulerAngleY;
                CGFloat ANGLE_VERTICAL = faceHeadEulerAngleZ;
                
                /* ------ */
                
                /*
                 - Plot points to visually with color on the screen.
                 */
                if (self.debug){
                    [cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
                    
                    [cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
                    [cameraDebug addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
                    
                    [cameraDebug addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
                    
                    [cameraDebug addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
                    
                    
                    [cameraDebug addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
                    [cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
                    
                    [cameraDebug addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
                    [cameraDebug addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
                    
                    [cameraDebug addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
                    
                    [cameraDebug addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
                    
                }
                
                /* ------ */
                
                BOOL hasError = NO;
                NSMutableString *strError = [NSMutableString new];
                
                if(IS_IPHONE_5) {
                    
                    if(!(((Y_LEFT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                           Y_LEFT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom]) || (Y_RIGHT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                                                                                                   Y_RIGHT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom])) &&
                         (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 6)  &&
                          X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 6) * 5)))) {
                        
                        
                        hasError = YES;
                        // [self showRed];
                        countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                        
                    }
                } else if (IS_IPHONE_X || IS_IPHONE_6P){
                    
                    if(Y_NOSEBASEPOSITION_POINT > ((SCREEN_HEIGHT/2)-80) &&
                       Y_NOSEBASEPOSITION_POINT < ((SCREEN_HEIGHT/2) + 40) &&
                       (X_LEFT_EAR_POINT > (SCREEN_WIDTH / 5)  &&
                        X_RIGHT_EAR_POINT < ((SCREEN_WIDTH / 5) * 4))) {
                        
                        hasError = NO;
                        
                    } else {
                        hasError = YES;
                        countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                    }
                } else {
                    
                    if(!(((Y_LEFT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                           Y_LEFT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom]) ||
                          (Y_RIGHT_EYE_POINT > [cameraFrame getOffsetTopPercent] &&
                           Y_RIGHT_EYE_POINT < [cameraFrame getSizePercentBetweenTopAndBottom])) &&
                         (X_LEFT_EAR_POINT > [cameraFrame getMarginOfSides] &&
                          X_RIGHT_EAR_POINT < SCREEN_WIDTH - [cameraFrame getMarginOfSides]))) {
                        
                        hasError = YES;
                        countTimeAlert ++;
                        [strError appendString:@"Center your face"];
                    }
                    
                }
                
                
                if( leftEarPosition != nil && rightEyePosition != nil)  {
                    
                    NSLog(@"Y_LEFT_EYE_POINT: %.2f - Y_RIGHT_EYE_POINT %.2f", Y_LEFT_EYE_POINT, Y_RIGHT_EYE_POINT);
                    NSLog(@"DIFERENCA ENTRE OLHOS Y: %.2f",fabs(Y_LEFT_EYE_POINT - rightEyePosition.y.doubleValue));
                    NSLog(@"DIFERENCA ENTRE OLHOS X: %.2f",fabs(leftEyePosition.x.doubleValue - Y_RIGHT_EYE_POINT));
                    
                    if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) > 220) {
                        countTimeAlert ++;
                        // [self showRed];
                        if(hasError){
                            [strError appendString:@" / Put your face away"];
                        }else{
                            [strError appendString:@"Put your face away"];
                        }
                        hasError = YES;
                        
                    }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < 120) {
                        countTimeAlert ++;
                        // [self showRed];
                        if(hasError){
                            [strError appendString:@" / Bring the face closer"];
                        }else{
                            [strError appendString:@"Bring the face closer"];
                        }
                        hasError = YES;
                        
                    }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
                        countTimeAlert ++;
                        if(hasError){
                            [strError appendString:@" / Inclined face"];
                        }else{
                            [strError appendString:@"Inclined face"];
                        }
                        hasError = YES;
                    }
                }
                
                [cameraDebug addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
                
                if (ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
                    countTimeAlert ++;
                    if (hasError){
                        if (ANGLE_HORIZONTAL > 20) {
                            [strError appendString:@" / Turn slightly left"];
                        } else if(ANGLE_HORIZONTAL < -20){
                            [strError appendString:@" / Turn slightly right"];
                        }
                    } else {
                        if (ANGLE_HORIZONTAL > 20) {
                            [strError appendString:@"Turn slightly left"];
                        } else if(ANGLE_HORIZONTAL < -20){
                            [strError appendString:@"Turn slightly right"];
                        }
                    }
                    hasError = YES;
                    
                }
                if (hasError) {
                    [self showAlert:strError];
                    hasError = NO;
                } else {
                    [cameraFrame showGreen]; // Face is centralized.
                }
            } else {
                [cameraFrame showGray];
            }
        }
    }];
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    
    if(self.cam != nil){
        [self.cam onSuccesCaptureFaceInsert:base64];
    }
    
}

@end
