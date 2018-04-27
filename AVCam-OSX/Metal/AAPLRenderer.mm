//
//  AAPLRenderer.mm
//  AVCOCV-OSX
//
//  Created by buza on 4/23/18.
//  Modified version of AAPLRenderer provided by Apple.
//

/*
 Copyright © 2017 Apple Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "AAPLRenderer.h"
#import "AAPLShaderTypes.h"

@implementation AAPLRenderer
{
    id<MTLDevice>                   _device;
    id<MTLRenderPipelineState>      _pipelineState;
    id<MTLCommandQueue>             _commandQueue;
    id<MTLTexture>                  _texture;
    id<MTLBuffer>                   _vertices;
    NSUInteger                      _numVertices;
    vector_uint2                    _viewportSize;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;

        float width = mtkView.frame.size.width;
        float height = mtkView.frame.size.height;

        static const AAPLVertex quadVertices[] =
        {
            { {  -width,  height },  { 0.f, 0.f } },
            { {   width,  height },  { 1.f, 0.f } },
            { {   width, -height },  { 1.f, 1.f } },
            
            { {  -width,  height },  { 0.f, 0.f } },
            { {   width, -height },  { 1.f, 1.f } },
            { {  -width, -height },  { 0.f, 1.f } },
        };

        _vertices = [_device newBufferWithBytes:quadVertices
                                         length:sizeof(quadVertices)
                                        options:MTLResourceStorageModeShared];

        _numVertices = sizeof(quadVertices) / sizeof(AAPLVertex);

        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];

        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Texturing Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;

        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        if (!_pipelineState)
        {
            NSLog(@"Failed to created pipeline state, error %@", error);
        }

        _commandQueue = [_device newCommandQueue];
    }

    return self;
}

- (void) updateWithImage:(nonnull IplImage*)image {
    
    if (!_texture) {
        MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];

        textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
        textureDescriptor.width = image->width;
        textureDescriptor.height = image->height;
        _texture = [_device newTextureWithDescriptor:textureDescriptor];
    }

    MTLRegion region = MTLRegionMake2D(0, 0, static_cast<NSUInteger>(image->width), static_cast<NSUInteger>(image->height));

    [_texture replaceRegion:region
                mipmapLevel:0
                  withBytes:image->imageData
                bytesPerRow:image->widthStep];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"cmdbuf";

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil)
    {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"encoder";

        double xx = (double)_viewportSize.x;
        double yy = (double)_viewportSize.y;
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, xx, yy, -1.0, 1.0 }];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setVertexBuffer:_vertices
                                offset:0
                              atIndex:AAPLVertexInputIndexVertices];
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:AAPLVertexInputIndexViewportSize];
        [renderEncoder setFragmentTexture:_texture
                                  atIndex:AAPLTextureIndexBaseColor];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_numVertices];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

@end

