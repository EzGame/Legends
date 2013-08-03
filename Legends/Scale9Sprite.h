#import "cocos2d.h"

@interface Scale9Sprite : CCNode <CCRGBAProtocol> {
    
    CCSpriteBatchNode *scale9Image;
    CCSprite *topLeft;
    CCSprite *top;
    CCSprite *topRight;
    CCSprite *left;
    CCSprite *centre;
    CCSprite *right;
    CCSprite *bottomLeft;
    CCSprite *bottom;
    CCSprite *bottomRight;
    
    // texture RGBA
    GLubyte    opacity;
    ccColor3B color;
    BOOL opacityModifyRGB_;
    
}

-(id) initWithFile:(NSString*)file centreRegion:(CGRect)centreRegion;
/** conforms to CocosNodeRGBA protocol */
@property (nonatomic,readwrite) GLubyte opacity;
/** conforms to CocosNodeRGBA protocol */
@property (nonatomic,readwrite) ccColor3B color;

@end