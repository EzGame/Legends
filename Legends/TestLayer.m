//
//  TestLayer.m
//  Legends
//
//  Created by David Zhang on 2013-06-17.
//
//

#import "TestLayer.h"
@interface TestLayer ()
@property (nonatomic, strong) CCSprite *testSprite;
@property (nonatomic, strong) CCSprite *testSprite2;
@property (nonatomic, strong) CCTMXTiledMap *map;
@end

@implementation TestLayer
@synthesize unit = _unit;
@synthesize display = _display;

+ (CCScene *) scene
{
    CCLOG(@"\n=========================<ENTERING TestLayer>=========================\n");
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TestLayer *layer = [TestLayer node];
    layer.tag = kTagForgeLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init]; //.0.
    
    if ( self )
    {
        isTouchEnabled_ = YES;
        
        _display = [UnitDisplay displayWithPosition:ccp(85,265)];
        [self addChild:_display z:100];
        
        
        _map = [CCTMXTiledMap tiledMapWithTMXFile:@"dev_map.tmx"];
        _map.scale = 1;
        _map.position = ccp(-100,-80);
        [self addChild:_map];
        
        NSArray *tokens = [@"u/1/0/str:0,agi:0,int:0,hp:100/-1/0,3" componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        _unit = [MudGolem mudGolemWithValues:tokens];
        //_unit = [Dragon dragonWithValues:tokens];
        _unit.delegate = self;
        _unit.sprite.position = ccp(100,100);
        [self addChild:_unit.spriteSheet z:SPRITES_TOP];
        [self addChild:_unit.menu z:MENUS];
        [_unit action:IDLE at:CGPointZero];
        [_unit toggleMenu:YES];
    }
    return self;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position;
    UITouch *touch = [touches anyObject];
    position = [touch locationInView: [touch view]];
    position = [[CCDirector sharedDirector] convertToGL: position];
    position = [self convertToNodeSpace:position];
    self.unit.sprite.position = position;
    NSLog(@"%@",NSStringFromCGPoint(position));
    self.unit.direction = (self.unit.direction + 1) % 4;
    [_unit action:ATTK at:ccp(-10,-10)];
    //[_unit action:MUDGOLEM_EARTHQUAKE at:_unit.sprite.position];
    //[_unit action:DRAGON_FIREBALL at:ccpAdd(_unit.sprite.position, ccp(-128,-96))];
    //[_unit action:MOVE at:position];
    //[_unit action:DRAGON_FLAMEBREATH at:ccpAdd(_unit.sprite.position,ccp(-32,-24))];
    //[_unit take:999];
}

- (void)addSprite:(CCSprite *)sprite z:(int)z
{
    [self addChild:sprite z:z];
}

- (void)removeSprite:(CCSprite *)sprite
{
}

- (void)killMe:(Unit *)unit at:(CGPoint)position
{
}

- (BOOL) pressedButton:(int)action
{
    return YES;
}
@end
