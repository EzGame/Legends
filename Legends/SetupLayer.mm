//
//  SetupLayer.m
//  myFirstApp
//
//  Created by David Zhang on 2012-12-16.
//
//
#define DRAG_SCROLL_MULTIPLIER 0.50
#define MAX_SCROLL_X 100
#define MAX_SCROLL_Y 50
#define MIN_SCROLL_X -100
#define MIN_SCROLL_Y -100

#import "SetupLayer.h"

@interface SetupLayer()
@property (nonatomic, strong)   SetupBrain *brain;
@property (nonatomic, strong)         Unit *unitPtr;
@end

@implementation SetupLayer
#pragma mark - Setters n Getters

#pragma mark - Init n Class
+ (CCScene *) scene
{
    CCLOG(@"=========================<ENTERING SetupLayer>=========================");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SetupLayer *layer = [[SetupLayer alloc] init];
    layer.tag = kTagSetupLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
    if ( self ) {
        isTouchEnabled_ = YES;
        winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        
        _setupLayer = [CCLayer node];
        [self addChild:_setupLayer z:GAMELAYER];
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:HUDLAYER];
        
        [self initMap];
        _brain = [[SetupBrain alloc] initWithMap:_tmxLayer delegate:self];
        [self initSaves];
        [self initTemp];
    }
    return self;
}

- (void) initMap
{
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"SetupMap.tmx"];
    _map.position = ccp(100, 200);
    _map.anchorPoint = ccp(0.5, 0.5);
    _tmxLayer = [_map layerNamed:@"tiles"];
    [_setupLayer addChild:_map z:MAP];
    
    // Do random tile
    gid_t gid = (arc4random()%4) + [_tmxLayer.tileset firstGid];
    for ( int i = 0 ; i < SETUPMAPWIDTH ; i++ ) {
        for ( int k = 0 ; k < SETUPMAPHEIGHT ; k++ ) {
            CGPoint pos = CGPointMake(i, k);
            if ( [_tmxLayer tileGIDAt:pos] != 0 )
                [_tmxLayer setTileGID:gid at:pos];
        }
    }
}

- (void) initSaves
{
    CGRect viewArea = CGRectMake(winSize.height - 120, 0, 120, winSize.width);
    NSMutableArray *setuplistPtr = [[UserSingleton get] setupList];
    _savedSetups = [SetupMenuLayer createWithView:viewArea setuplist:setuplistPtr delegate:self];
    [_hudLayer addChild:_savedSetups z:HUDLAYER];
}

- (void) initTemp
{
    _debug = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
    _debug.position = ccp(440,25);
    _debug.scale = 0.65;
    [_hudLayer addChild:_debug];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position;
    UITouch *touch = [touches anyObject];
    position = [touch locationInView: [touch view]];
    position = [[CCDirector sharedDirector] convertToGL: position];
    position = [self convertToNodeSpace:position];
    
    // Remove previous menu no matter what
    if ( [self.hudLayer getChildByTag:kTagSetupUnitMenu] != nil )
        [self.hudLayer removeChildByTag:kTagSetupUnitMenu cleanup:YES];
    
    // Call start
    self.unitPtr = [self.brain touchStarted:position];
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView: [touch view]];
        CGPoint previousLocation = [touch previousLocationInView: [touch view]];
        
        // Moving unit
        if ( self.unitPtr != nil ) {
            touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
            touchLocation = [self.setupLayer convertToNodeSpace:touchLocation];
            
            self.unitPtr.position = touchLocation;
            return;
            
        // Moving screen
        } else {
            scrolled = YES;
            CGPoint difference = ccpSub(touchLocation, previousLocation);
            
            CGPoint change = ccp(difference.x * DRAG_SCROLL_MULTIPLIER,
                                 -difference.y * DRAG_SCROLL_MULTIPLIER);
            
            CGPoint pos = ccpAdd(self.setupLayer.position, change);
            if ( pos.x > MAX_SCROLL_X )
                pos = ccp(MAX_SCROLL_X, pos.y);
            if ( pos.y > MAX_SCROLL_Y )
                pos = ccp(pos.x, MAX_SCROLL_Y);
            if ( pos.x < MIN_SCROLL_X )
                pos = ccp(MIN_SCROLL_X, pos.y);
            if ( pos.y < MIN_SCROLL_Y )
                pos = ccp(pos.x, MIN_SCROLL_Y);
            
            self.setupLayer.position = pos;
            self.brain.currentLayerPosition = pos;
        }
	}
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( scrolled ) {
        scrolled = NO;
        
    } else if ([touches count] == 1) {
        CGPoint position;
        UITouch *touch = [touches anyObject];
        position = [touch locationInView: [touch view]];
        position = [[CCDirector sharedDirector] convertToGL: position];
        position = [self convertToNodeSpace:position];
        
        [self.debug setString:[NSString stringWithFormat:@"%@", NSStringFromCGPoint(position)]];
        
        [self.brain touchEnded:position unit:self.unitPtr];
        self.unitPtr = nil;
    }
}

- (void) reorderTile:(Tile *)tile
{
    int pos = tile.boardPos.x + tile.boardPos.y;
    [self.setupLayer reorderChild:tile.unit z:SPRITES_TOP - pos];
}

- (void) changeLayerState:(SetupLayerState)state
{
    
}

#pragma mark - Setup Brain Delegate
- (void) setupBrainNeedsUnitMenuAt:(CGPoint)position
{
    // Adjust position
    int x, y;
    x = (position.x + 120 > winSize.height - 120) ? position.x - 120 : position.x + 20;
    y = (position.y + 120 > winSize.width) ? position.y - 80 : position.y + 20;
    CGRect viewArea = CGRectMake(x, y, 100, 100);
    
    // Get list and make layer
    NSMutableArray *unitlist = [[UserSingleton get] unitList];
    SetupUnitMenuLayer *units = [SetupUnitMenuLayer createWithView:viewArea
                                                              list:unitlist
                                                          delegate:self];
    units.tag = kTagSetupUnitMenu;
    [self.hudLayer addChild:units z:MENUS];
}

- (void) setupBrainDidLoadUnitAt:(Tile *)tile
{
    [self.setupLayer addChild:tile.unit z:SPRITES_TOP];
    [self reorderTile:tile];
    [tile.unit.sprite runAction:
     [CCSpawn actions:[CCFadeIn actionWithDuration:0.3], nil]];
    
    // Remove menu
    [self.hudLayer removeChildByTag:kTagSetupUnitMenu cleanup:YES];
}

- (void) setupBrainDidRemoveUnit:(Unit *)unit
{
    [unit.sprite runAction:
     [CCSequence actions:
      [CCFadeOut actionWithDuration:0.3],
      [CCCallBlock actionWithBlock:^{ [self.setupLayer removeChild:unit cleanup:YES]; }],
      nil]];
}

- (void) setupBrainDidMoveUnitTo:(Tile *)tile
{
    [self reorderTile:tile];
}

#pragma mark - SetupUnitMenuLayer and SetupMenuLayer Delegate
- (void) setupUnitMenuLayerWantsToLoadUnit:(NSMutableDictionary *)unit
{
    [self.brain addUnit:[UnitObject createWithDict:unit]];
}

- (void) setupMenuLayerWantsToLoadSetup:(NSMutableDictionary *)setup
{
    NSString *name = [setup objectForKey:@"name"];
    
    // If the new button is pressed, we want to have an empty board
    if ( [name isEqualToString:@"new"] ) {
        
        
        
    // Load setup and open up queue button
    } else {
        NSLog(@"SetupLayer: Got a setup named %@", name);

        for ( NSString *key in setup ) {
            if ( ![key isEqualToString:@"name"] ) {
                NSMutableDictionary *unitDict = [setup objectForKey:key];
                UnitObject *obj = [UnitObject createWithDict:unitDict];
                [self.brain addUnit:obj];
            }
        }
    }
        
}
@end