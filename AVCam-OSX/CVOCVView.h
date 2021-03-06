/*
 *  CVOCVView.h
 *
 *  Created by buza on 10/02/08.
 *
 *  Brought to you by buzamoto. http://buzamoto.com
 */

#import <opencv/cv.h>
#import <Cocoa/Cocoa.h>

#define glReportError()                             \
{                                                   \
    GLenum error=glGetError();                      \
    if(GL_NO_ERROR!=error)                          \
    {                                               \
        printf("GL error at %s:%d: %s\n",__FILE__,__LINE__,(char*)gluErrorString(error));   \
    }                                               \
}                                                   \

#define IMAGE_CACHE_SIZE 3

struct cvTexture {
    GLuint texId;
    IplImage *texImage;
    short initialized;
};

@interface CVOCVView : NSOpenGLView 
{
    @public
    
        int imageIndex;
        struct cvTexture cvTextures[IMAGE_CACHE_SIZE];
    
        GLuint rectList;
}

//If we want to draw using textures.
-(void) doTexture:(struct cvTexture*)cvTex;

@end
