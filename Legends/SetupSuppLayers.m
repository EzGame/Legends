//
//  SetupSuppLayers.m
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//

#import "SetupSuppLayers.h"

@implementation SetupMenuLayer

+ (SetupMenuLayer *) createWithView:(CGRect)area
                          setuplist:(NSMutableArray *)setuplist
                           delegate:(id<SetupMenuLayerDelegate>)delegate
{
    return [[SetupMenuLayer alloc] initWithArea:area
                                      setuplist:setuplist
                                       delegate:delegate];
}

- (id) initWithArea:(CGRect)area
          setuplist:(NSMutableArray *)setuplist
           delegate:(id<SetupMenuLayerDelegate>)delegate
{
    self = [super init];
    if ( self ) {
        // Save View area and delegate
        _viewArea = area;
        _delegate = delegate;
        
        // Create background and add
        background = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255*.25)];
        [background changeWidth:area.size.width height:area.size.height];
        background.position = area.origin;
        [self addChild:background];
        
        // Handle setuplist
        NSMutableArray *setuplistPtr = setuplist;
        if ( setuplistPtr == nil ) {
            NSLog(@"SetupMenuLayer: User setup list nil, making empty list");
            setuplistPtr = [NSMutableArray array];
            
            // TODO: remove temp
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            [temp setObject:@"Shit" forKey:@"name"];
            for ( UnitType i = 1; i <= UnitTypeLast; i++ ) {
                NSMutableDictionary *unitDict = [NSMutableDictionary dictionary];
                [[UserSingleton get] setDict:unitDict forType:i at:CGPointMake(i, 2)];
                
                // Find key with unit name
                NSString *key = [GeneralUtils stringFromType:i];
                [temp setObject:unitDict forKey:key];
            }
            
            [setuplistPtr addObject:[SetupNode createWithDict:temp]];
        }
        
        // Add the new button
        SetupNode *newNode = [SetupNode createWithDict:
                              [NSMutableDictionary dictionaryWithObject:@"New"
                                                                 forKey:@"name"]];
        [setuplistPtr addObject:newNode];
        
        // Create CCScrollLayer
        _setups = [CCScrollLayer createLayerWithNodes:setuplistPtr
                                             viewRect:area
                                            direction:ccp(0,1)];
        _setups.delegate = self;
        [self addChild:_setups];
        
        // Return first setup // TODO: save last used setup for usage here
        [self.delegate setupMenuLayerWantsToLoadSetup:[[setuplistPtr firstObject] dict]];
    }
    return self;
}

- (void) scrollLayerReceivedTouchFor:(id<NodeReporter>)obj
{
    // Get the name from obj
    SetupNode *nodePtr = (SetupNode *)obj;
    NSString *name = [nodePtr.dict objectForKey:@"name"];
    
    // If the new button is pressed
    if ( [name isEqualToString:@"New"] ) {
        
    // Else, load setup
    } else {
        [self.delegate setupMenuLayerWantsToLoadSetup:nodePtr.dict];
    }
}
@end

@implementation SetupNode
+ (SetupNode *) createWithDict:(NSMutableDictionary *)dict
{
    return [[SetupNode alloc] initWithDict:dict];
}

- (id) initWithDict:(NSMutableDictionary *)dict
{
    self = [super init];
    if ( self ) {
        // Save dict
        _dict = dict;
        
        // Get name and make label
        NSString *name = [_dict objectForKey:@"name"];
        _label = [CCLabelBMFont labelWithString:name fntFile:@"font_normal_big.fnt"];
        _label.anchorPoint = ccp(0.5, 1);
        [self addChild:_label z:1];
        
        // Make button
        _button = [CCSprite spriteWithFile:@"setupButton.png"];
        _button.anchorPoint = ccp(0.5, 1);
        [self addChild:_button z:0];
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
@end








#pragma mark - Setup Unit Menu Layer, similar to Setup Menu Layer
@implementation SetupUnitMenuLayer

+ (SetupUnitMenuLayer *) createWithView:(CGRect)area
                                   list:(NSMutableArray *)unitlist
                               delegate:(id<SetupUnitMenuLayerDelegate>)delegate;
{
    return [[SetupUnitMenuLayer alloc] initWithArea:area
                                               list:unitlist
                                           delegate:delegate];
}

- (id) initWithArea:(CGRect)area
               list:(NSMutableArray *)unitlist
           delegate:(id<SetupUnitMenuLayerDelegate>)delegate;
{
    self = [super init];
    if ( self ) {
        // Save area and delegate
        _viewArea = area;
        _delegate = delegate;
        
        // Handle list
        NSMutableArray *unitlistPtr = [NSMutableArray arrayWithArray:unitlist];
        for (int i = 0; i < unitlistPtr.count; i++) {
            SetupUnitNode *newNode = [SetupUnitNode createWithDict:[unitlist objectAtIndex:i]];
            [unitlistPtr replaceObjectAtIndex:i withObject:newNode];
        }
        
        // Create scroll layer
        _units = [CCScrollLayer createLayerWithNodes:unitlistPtr
                                            viewRect:area
                                           direction:ccp(0,1)];
        _units.delegate = self;
        [self addChild:_units];
    }
    return self;
}

- (void) scrollLayerReceivedTouchFor:(id<NodeReporter>)obj
{
#ifdef DEVMODE
    // Dev mode, create random unit of type from no where
    SetupUnitNode *nodePtr = (SetupUnitNode *)obj;
    [self.delegate setupUnitMenuLayerWantsToLoadUnit:nodePtr.dict];
#else
    // Non-dev, get unit list
    NSAssert(false, @"NON DEV MODE NOT IMPLEMENTED YET");
#endif
}
@end

@implementation SetupUnitNode

+ (SetupUnitNode *) createWithDict:(NSMutableDictionary *)dict
{
    return [[SetupUnitNode alloc] initWithDict:dict];
}

- (id) initWithDict:(NSMutableDictionary *)dict
{
    self = [super init];
    if ( self ) {
        // Save dict
        _dict = dict;
        
        // Get name and make label
        NSString *name = [_dict objectForKey:@"name"];
        _label = [CCLabelBMFont labelWithString:name fntFile:@"font_normal_small.fnt"];
        _label.anchorPoint = ccp(0.5, 1);
        [self addChild:_label z:1];
        
        // Make button
        _button = [CCSprite spriteWithFile:@"setupUnitButton.png"];
        _button.anchorPoint = ccp(0.5, 1);
        [self addChild:_button z:0];
    }
    return self;
}

- (float) height
{
    return 20;
}

- (float) width
{
    return 100;
}

- (NSString *) description
{
    NSLog(@"%@",self.dict);
    return [super description];
}
@end