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
        
        int type = UnitTypePriest;
        int experience = 1000000;
        int str = (arc4random() % 100 );
        int agi = (arc4random() % 100 );
        int inte = (arc4random() % 100 );
        int wis = (arc4random() % 100 );
        int hp = (arc4random() % 100 );
        NSString *string = [NSString stringWithFormat:@"%d/%d/%d/%d/%d/%d/%d/%@/{-1,-1}/0",
                            type, experience, str, agi, inte, wis, hp, nil];
        UnitObject *obj = [[UnitObject alloc] initWithString:string];
        _unit = [Priest priest:obj isOwned:YES];
        _unit.position = ccp(100, 100);
        
        _target = [Priest priest:obj isOwned:YES];
        _target.position = ccp(200, 200);
        
        [self addChild:_unit];
        [self addChild:_target];
        
//        if ( 0 ){
//            UnitObj *unit = [UnitObj unitObjWithString:string];
//            _unit = [LionMage lionmageForSide:YES withObj:unit];
//            _unit.delegate = self;
//            _unit.position = ccp(100,100);
//            [self addChild:_unit z:SPRITES_TOP];
//
//            _target = [LionMage lionmageForSide:YES withObj:unit];
//            _target.delegate = self;
//            _target.position = ccp(200,200);
//            [self addChild:_target z:SPRITES_TOP];
//
//            _mud = [MudGolem mudGolemFor:YES withObj:unit];
//            _mud.delegate = self;
//            _mud.position = ccp(300,300);
//            [self addChild:_mud z:SPRITES_TOP];
//        }
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
    NSLog(@"%@",NSStringFromCGPoint(position));
    if ( 1 ) {
        self.unit.position = position;
        self.unit.direction = (self.unit.direction + 1) % 4;
        [self.unit action:0 targets:[NSMutableArray arrayWithObjects:self.unit, self.target, nil]];
    }
}

- (BOOL) unitDelegatePressedButton:(Action)action
{
    NSLog(@">[MYLOG]    Received action %d",action);
    return YES;
}

- (void) unitDelegateKillMe:(Unit *)unit at:(CGPoint)position
{
    NSLog(@"Unit requested suicide");
}

- (void) unitDelegateAddSprite:(CCSprite *)sprite z:(ZORDER)z
{
    NSLog(@"Unit requested add sprite");
    [self addChild:sprite z:z];
}

- (void) unitDelegateRemoveSprite:(CCSprite *)sprite
{
    NSLog(@"Unit requested remove sprite");
    [self removeChild:sprite cleanup:YES];
}

- (void) unitDelegateUnit:(Unit *)unit finishedAction:(Action)action
{
    NSLog(@"Unit %@ finished action %d", unit, action);
}

- (void) unitDelegateShakeScreen
{
    NSLog(@"Unit requested screen shake");
    CCAction *shake = [CCSequence actions:
                       [CCShake actionWithDuration:0.75 amplitude:ccp(10,10) dampening:YES], nil];
    shake.tag = 10;
    [self runAction:shake];
}

- (void) unitDelegateDisplayCombatMessage:(NSString *)message
                               atPosition:(CGPoint)point
                                withColor:(ccColor3B)color
                                   isCrit:(BOOL)isCrit;
{
    NSLog(@">[MYLOG]        Displaying %@, at [%f,%f]",message,point.x,point.y);
    //used in determining how long the slide/fade lasts
    float slideDuration = 0.6;
    
    //used in determining how far up/down along Y the label changes
    //positive = UP, negative = DOWN
    float yChange = 35;
    
    //used in determining how far left/right along the X the label changes
    //positive = RIGHT, negative = LEFT
    float xChange = 0;
    
    //set up the label
    CCLabelBMFont *lblMessage = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    
    //Change the color
    lblMessage.color = color;
    
    //position the label where you want it...
    lblMessage.position = ccp(point.x,point.y+25);
    
    //add the LABEL to the screen
    [self addChild:lblMessage z:DISPLAYS];
    
    id slideUp = [CCMoveBy actionWithDuration:slideDuration position:ccp(xChange,yChange)];
    id fadeOut = [CCFadeOut actionWithDuration:2];
    
    //run the actions on the LABEL
    id text = [CCSequence actions:slideUp, fadeOut, nil];
    [lblMessage runAction:text];
    
    //the waiting for the slide/fade to complete
    id waitForSlide = [CCDelayTime actionWithDuration:2.5];
    
    //the actual removal of the label (uses a block so all the code stays here)
    id removeLabel = [CCCallBlock actionWithBlock:^{
        [self removeChild:lblMessage cleanup:YES];
    }];
    
    //sequence them together so they happen IN ORDER (not at once)
    id sequence = [CCSequence actions:waitForSlide, removeLabel, nil];
    
    //actually run the sequence
    [self runAction:sequence];
}
@end
