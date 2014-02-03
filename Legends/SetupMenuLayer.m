//
//  SetupMenuLayer.m
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//

#import "SetupMenuLayer.h"

@implementation SetupMenuLayer

+ (SetupMenuLayer *) createWithView:(CGRect)area
{
    return [[SetupMenuLayer alloc] initWithArea:area];
}

- (id) initWithArea:(CGRect)area;
{
    self = [super init];
    if ( self ) {
        _viewArea = area;
        
        background = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255*.25)];
        [background changeWidth:area.size.width height:area.size.height];
        background.position = area.origin;
        [self addChild:background];
        
        [self initItems];
        
        setups = [CCScrollLayer createLayerWithNodes:items viewRect:area direction:ccp(0,1)];
        [self addChild:setups];
    }
    return self;
}
                  
- (void) initItems
{
    // Access file and open any setups
    items = [NSMutableArray array];
    
    // TODO: Server side storage for setups
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"Test/"]];
    [items addObject:[SetupNode setupWithString:@"Test2/"]];
    [items addObject:[SetupNode setupWithString:@"New"]];
}
@end

@implementation SetupNode

+ (SetupNode *) setupWithString:(NSString *)setup
{
    return [[SetupNode alloc] initWithString:setup];
    
}

- (id) initWithString:(NSString *)string
{
    self = [super init];
    if ( self ) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:
                           [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        int tokenCount = [tokens count];
        
        NSString *name = [tokens objectAtIndex:0];
        label = [CCLabelBMFont labelWithString:name fntFile:@"font_normal_big.fnt"];
        label.anchorPoint = ccp(0.5, 1);
        [self addChild:label z:1];
        
        if (tokenCount > 1)
            _string = [tokens objectAtIndex:1];
        
        button = [CCSprite spriteWithFile:@"setupButton.png"];
        button.anchorPoint = ccp(0.5, 1);
        [self addChild:button z:0];
    }
    return self;
}

- (float) height
{
    return 40;
}

- (float) width
{
    return 100;
}

- (NSString *) data
{
    return self.string;
}
@end