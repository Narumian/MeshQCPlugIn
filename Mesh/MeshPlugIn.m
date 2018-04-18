//
//  MeshPlugIn.m
//  Mesh
//
//  Created by Narumi on 2017/07/11.
//  Copyright © 2017年 Narumi Inada. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "MeshPlugIn.h"

#define    kQCPlugIn_Name                @"Mesh"
#define    kQCPlugIn_Description        @"Mesh description"

@implementation MeshPlugIn

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputVertices, inputColors, inputNormals, inputTexCoords, inputMode,inputBlendMode,inputCullMode ,inputsize ,inputTexture,inputX,inputY,inputZ,inputRotationX,inputRotationY,inputRotationZ,inputScale;

+ (NSDictionary *)attributes
{
    // Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    // Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    if([key isEqualToString:@"inputMode"])
        return  @{QCPortAttributeNameKey : @"Mode",
                  QCPortAttributeMenuItemsKey : @[@"GL_POINTS",@"GL_LINES",@"GL_LINE_LOOP",@"GL_LINE_STRIP",@"GL_TRIANGLES",@"GL_TRIANGLE_STRIP",@"GL_TRIANGLE_FAN",@"GL_QUADS",@"GL_QUAD_STRIP",@"GL_POLYGON",@"POINTSPRITE"],
                  QCPortAttributeMinimumValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeDefaultValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeMaximumValueKey : [NSNumber numberWithUnsignedInteger:10]};
    
    if([key isEqualToString:@"inputBlendMode"])
        return  @{QCPortAttributeNameKey : @"BlendMode",
                  QCPortAttributeMenuItemsKey : @[@"REPLACE",@"OVER",@"ADD"],
                  QCPortAttributeMinimumValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeDefaultValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeMaximumValueKey : [NSNumber numberWithUnsignedInteger:2]};
    if([key isEqualToString:@"inputCullMode"])
        return  @{QCPortAttributeNameKey : @"CullingMode",
                  QCPortAttributeMenuItemsKey : @[@"None",@"FrontFaces",@"BackFaces",@"Front&Back Faces"],
                  QCPortAttributeMinimumValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeDefaultValueKey : [NSNumber numberWithUnsignedInteger:0],
                  QCPortAttributeMaximumValueKey : [NSNumber numberWithUnsignedInteger:3]};
    
    /*
     GL_POINTS                         0x0000
     #define GL_LINES                          0x0001
     #define GL_LINE_LOOP                      0x0002
     #define GL_LINE_STRIP                     0x0003
     #define GL_TRIANGLES                      0x0004
     #define GL_TRIANGLE_STRIP                 0x0005
     #define GL_TRIANGLE_FAN                   0x0006
     #define GL_QUADS                          0x0007
     #define GL_QUAD_STRIP                     0x0008
     #define GL_POLYGON
     */
    
    return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
    // Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
    return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode
{
    // Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
    return kQCPlugInTimeModeNone;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Allocate any permanent resource required by the plug-in.
        //self.outputDebug = @"AAA";
        
        
    }
    
    return self;
}


@end

@implementation MeshPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
    // Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
    // Return NO in case of fatal failure (this will prevent rendering of the composition to start).
    
    return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
    // Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
    CGLContextObj cgl_ctx = [context CGLContextObj];
    //GL_TRIANGLES
    GLuint mode;
    //GL_LINES
    
    
    
    switch(self.inputMode){
        case 0:mode = 0x0000;break;
        case 1:mode = 0x0001;break;
        case 2:mode = 0x0002;break;
        case 3:mode = 0x0003;break;
        case 4:mode = 0x0004;break;
        case 5:mode = 0x0005;break;
        case 6:mode = 0x0006;break;
        case 7:mode = 0x0007;break;
        case 8:mode = 0x0008;break;
        case 9:mode = 0x0009;break;
        case 10:mode = 0x0000;break;
        default:mode = 0x0000;break;
    }
    
    NSInteger colorSize,normSize,coordSize;
    
    colorSize = [self.inputColors count];
    normSize = [self.inputNormals count];
    coordSize = [self.inputTexCoords count];
    
    BOOL safe = YES;
    BOOL alpha = NO;
    BOOL withw = NO;
    BOOL withwN = NO;
    if([self.inputVertices count] > 0 && [[self.inputVertices objectAtIndex:0] isKindOfClass:[NSArray class]]){
        if([[self.inputVertices objectAtIndex:0] count] == 3){
            safe = YES;
        }else if([[self.inputVertices objectAtIndex:0] count] == 4){
            withw = YES;
            safe = YES;
        }else{
            safe = NO;
            
        }
    }else{
        safe = NO;
        
    }
    
    if(colorSize>0){
        if([[self.inputColors objectAtIndex:0] isKindOfClass:[NSArray class]]){
            if([[self.inputColors objectAtIndex:0] count] == 3){
                safe = YES;
            }else if([[self.inputColors objectAtIndex:0] count] == 4){
                safe = YES;
                alpha = YES;
            }else{
                safe = NO;
            }
        }else{
            safe = NO;
        }
    }
    
    
    if(coordSize>0){
        if([[self.inputTexCoords objectAtIndex:0] isKindOfClass:[NSArray class]]){
            if([[self.inputTexCoords objectAtIndex:0] count] == 2){
                safe = YES;
            }else{
                safe = NO;
            }
        }else{
            safe = NO;
        }
    }
    
    if(normSize>0){
        if([[self.inputNormals objectAtIndex:0] isKindOfClass:[NSArray class]]){
            if([[self.inputNormals objectAtIndex:0] count] == 3){
                safe = YES;
            }else if([[self.inputNormals objectAtIndex:0] count] == 4){
                safe = YES;
                withwN = YES;
            }else{
                safe = NO;
            }
        }else{
            safe = NO;
        }
     }
     
    
    
    if(safe){
        //glDepthMask(GL_FALSE);
        glEnable(GL_BLEND);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_NORMALIZE);
        glActiveTexture(GL_TEXTURE0);
        //glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
        /*if(alpha){
            
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
        }else{
            
            
            
        }*/
        
        switch(self.inputBlendMode){
            case 0:glBlendFunc(GL_ONE, GL_ZERO);break;
            case 1:glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);break;
            case 2:glBlendFunc(GL_ONE, GL_ONE);break;
            default:break;
                
        }
        
        if(self.inputCullMode!=0){
            //glFrontFace(GL_CCW);
            glEnable(GL_CULL_FACE);
        }
        switch(self.inputCullMode){
            case 0:break;
            case 1:glCullFace(GL_FRONT);
            case 2:glCullFace(GL_BACK);
            case 3:glCullFace(GL_FRONT_AND_BACK);
            default:break;
        }
        
        
        
        id<QCPlugInInputImageSource>    image;
        GLuint textureName;
        GLint saveMode;
        
        
        image = self.inputTexture;
        
        if(image && [image lockTextureRepresentationWithColorSpace:([image shouldColorMatch] ? [context colorSpace] : [image imageColorSpace] ) forBounds:[image imageBounds]])textureName = [image textureName];
        else textureName = 0;
        
        glGetIntegerv(GL_MATRIX_MODE, &saveMode);
        glMatrixMode(GL_MODELVIEW);
        if(textureName){
            glEnable([image textureTarget]);
            [image bindTextureRepresentationToCGLContext:cgl_ctx textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
            
            
        }
        
        
        
        
        if(mode==GL_POINTS){
            
            if(self.inputMode == 10){//point sprite
                glActiveTexture(GL_TEXTURE0);
                glEnable(GL_POINT_SPRITE);
                if([image textureTarget] == GL_TEXTURE_2D)glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                glTexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);

            }
            
            glPointSize(self.inputsize);
        }else{
            if(self.inputMode == 1||self.inputMode == 2||self.inputMode == 3){
            glLineWidth(self.inputsize);
            }
        }
        
        glPushMatrix();
        glScaled(self.inputScale, self.inputScale, self.inputScale);
        glTranslated(self.inputX, self.inputY, self.inputZ);
        glRotated(self.inputRotationX, 1.0, 0.0, 0.0);
        glRotated(self.inputRotationY, 0.0, 1.0, 0.0);
        glRotated(self.inputRotationZ, 0.0, 0.0, 1.0);
        
        
        glBegin(mode);
        
        
        
        for(NSInteger i = 0; i < [self.inputVertices count]; i++){
            if(i<colorSize){
                if(alpha){
                    glColor4f([[self.inputColors objectAtIndex:i][0] floatValue], [[self.inputColors objectAtIndex:i][1] floatValue], [[self.inputColors objectAtIndex:i][2] floatValue],[[self.inputColors objectAtIndex:i][3] floatValue]);
                }
                else{
                    glColor3f([[self.inputColors objectAtIndex:i][0] floatValue], [[self.inputColors objectAtIndex:i][1] floatValue], [[self.inputColors objectAtIndex:i][2] floatValue]);
                }
            }
            
            
            if(i<normSize){
                
               
                    glNormal3f([[self.inputNormals objectAtIndex:i][0] floatValue], [[self.inputNormals objectAtIndex:i][1] floatValue], [[self.inputNormals objectAtIndex:i][2] floatValue]);
                
            }
            
            if(i<coordSize)glTexCoord2f([self.inputTexCoords[i][0] floatValue], [self.inputTexCoords[i][1] floatValue]);
            
            if(withw){
                glVertex4f([[self.inputVertices objectAtIndex:i][0] floatValue], [[self.inputVertices objectAtIndex:i][1] floatValue], [[self.inputVertices objectAtIndex:i][2] floatValue],[[self.inputVertices objectAtIndex:i][3] floatValue]);
            }else{
                glVertex3f([[self.inputVertices objectAtIndex:i][0] floatValue], [[self.inputVertices objectAtIndex:i][1] floatValue], [[self.inputVertices objectAtIndex:i][2] floatValue]);
            }
        }
        
        
        glColor3f(1.0,1.0,1.0);
        glEnd();
        
        glPopMatrix();
        glDisable(GL_BLEND);
        glDisable(GL_CULL_FACE);
        //glBindTexture(tgt,0);
        //glDisable(tgt);
        glMatrixMode(saveMode);
       
        
        if(mode==GL_POINT){
            
            if(self.inputMode == 10){//point sprite
                glDisable(GL_POINT_SPRITE);
                glTexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_FALSE);
                
            }
            glPointSize(0);
        }else{
            if(self.inputMode == 1||self.inputMode == 2||self.inputMode == 3)glLineWidth(0);
        }
        if(textureName){
            [image unbindTextureRepresentationFromCGLContext:cgl_ctx textureUnit:GL_TEXTURE0];
            [image unlockTextureRepresentation];
            
        }
        
        
        
    }
    
    //glvertexpoi
    
    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
    // Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
    // Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
