//
//  MeshPlugIn.h
//  Mesh
//
//  Created by Narumi on 2017/07/11.
//  2017年 Narumi Inada.Use for free.
//

#import <Quartz/Quartz.h>
#import <GLKit/GLKit.h>

@interface MeshPlugIn : QCPlugIn
{
    
}

@property (assign) double inputX;
@property (assign) double inputY;
@property (assign) double inputZ;
@property (assign) double inputRotationX;
@property (assign) double inputRotationY;
@property (assign) double inputRotationZ;
@property (assign) double inputScale;

@property (assign)NSArray* inputVertices;
@property (assign)NSArray* inputColors;
@property (assign)NSArray* inputNormals;
@property (assign)NSArray* inputTexCoords;
@property (assign) NSUInteger inputMode;
@property (assign) NSUInteger inputBlendMode;
@property (assign) NSUInteger inputCullMode;
@property (assign) double inputsize;
@property (assign) id<QCPlugInInputImageSource> inputTexture;

//@property (assign) NSString* outputDebug;

// Declare here the properties to be used as input and output ports for the plug-in e.g.
//@property double inputFoo;
//@property (copy) NSString* outputBar;

@end
