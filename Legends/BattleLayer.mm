//
//  BattleLayer.m
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//
#define DRAG_SCROLL_MULTIPLIER 0.50
#define PINCH_ZOOM_MULTIPLIER 0.003
#define MAX_ZOOM 1.1
#define MIN_ZOOM 0.375
#define MAX_SCROLL_X 0
#define MAX_SCROLL_Y 0
#define MIN_SCROLL_X -135
#define MIN_SCROLL_Y -200

#import "BattleLayer.h"
#import "MainMenuViewController.h"

@interface BattleLayer()
@property (nonatomic, strong) BattleBrain *brain;
@end

@implementation BattleLayer
#pragma mark - Setters n Getters

#pragma mark - Init n Class
+ (CCScene *) sceneWithMatch:(MatchObject *)obj
{
    CCLOG(@"=========================<ENTERING BattleLayer>=========================");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BattleLayer *layer = [[BattleLayer alloc] initWithMatch:obj];
    layer.tag = kTagBattleLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)initWithMatch:(MatchObject *)obj
{
    self = [super init];
    if ( self ) {
        isTouchEnabled_ = YES;
        winSize = [[CCDirector sharedDirector] winSize];
        
        _matchObj = obj;
        
        _gameLayer = [CCLayer node];
        CCSprite *filter = [CCSprite spriteWithFile:@"blackpixel.png"];
        filter.opacity = 256*0.25;
        filter.scale = 1000;
        filter.position = ccp(500,500);
        filter.anchorPoint = ccp(0.5,0.5);
        [_gameLayer addChild:filter z:FILTER];
        
        [self addChild:_gameLayer z:GAMELAYER];
        
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:HUDLAYER];
        
        [self initMap];
        [self initTemp];
        [self initResource];
        
        _brain = [[BattleBrain alloc] initWithMap:_tmxLayer delegate:self];
        
        if ( [_matchObj.myUser isItMe] ) {
            turnState = TurnStateA;
        }
    }
    return self;
}

- (void) initMap
{
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"GameMap.tmx"];
    
    _tmxLayer = [_map layerNamed:@"tiles"];
    [_gameLayer addChild:_map z:MAP];
    
    // Do random tile
    gid_t gid = (arc4random()%4) + [_tmxLayer.tileset firstGid];
    for ( int i = 0 ; i < GAMEMAPWIDTH ; i++ ) {
        for ( int k = 0 ; k < GAMEMAPHEIGHT ; k++ ) {
            CGPoint pos = CGPointMake(i, k);
            if ( [_tmxLayer tileGIDAt:pos] != 0 )
                [_tmxLayer setTileGID:gid at:pos];
        }
    }
}

- (void) initResource
{
    _me = [PlayerResources playerResource];
    _me.position = ccp(0,312);
    [_hudLayer addChild:_me z:HUDLAYER];
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
    // Do nothing atm
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
        scroll = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView: [touch view]];
        CGPoint previousLocation = [touch previousLocationInView: [touch view]];
        CGPoint difference = ccpSub(touchLocation, previousLocation);
        
        CGPoint change = ccp(difference.x * DRAG_SCROLL_MULTIPLIER,
                             -difference.y * DRAG_SCROLL_MULTIPLIER);
        
        CGPoint pos = ccpAdd(self.gameLayer.position, change);
        if ( pos.x > MAX_SCROLL_X )
            pos = ccp(MAX_SCROLL_X, pos.y);
        if ( pos.y > MAX_SCROLL_Y )
            pos = ccp(pos.x, MAX_SCROLL_Y);
        if ( pos.x < MIN_SCROLL_X )
            pos = ccp(MIN_SCROLL_X, pos.y);
        if ( pos.y < MIN_SCROLL_Y )
            pos = ccp(pos.x, MIN_SCROLL_Y);
        
        self.gameLayer.position = pos;
        self.brain.currentLayerPosition = pos;
        
//        NSLog(@"New pos is %f %f",pos.x,pos.y);
	}
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( scroll ) {
        scroll = NO;
        
    } else if ([touches count] == 1) {
        CGPoint position;
        UITouch *touch = [touches anyObject];
        position = [touch locationInView: [touch view]];
        position = [[CCDirector sharedDirector] convertToGL: position];
        position = [self convertToNodeSpace:position];
        
        [self.debug setString:[NSString stringWithFormat:@"%@", NSStringFromCGPoint(position)]];
        //[self.brain lightUp:position];
        
        [self.brain turn_driver:position];
//        [self animTest:position];
    }
}

- (void) animTest:(CGPoint)position;
{
    NSLog(@"fireball");
    SkillAnimation *fireball = [SkillAnimation SkillAnimation:@"fireball" TTL:2];
    fireball.scale = 0.5;
    [self addChild:fireball z:EFFECTS];
    [fireball shootTo:position duration:2];
}


#pragma mark - Helper Functions
- (void) reorderTile:(Tile *)tile
{
    int pos = tile.boardPos.x + tile.boardPos.y;
    [self.gameLayer reorderChild:tile.unit z:SPRITES_TOP - pos];
}


#pragma mark - BattleBrain Delegates
- (void) battleBrainDidLoadUnitAt:(Tile *)tile
{
    NSLog(@"position %@, %@", NSStringFromCGPoint(tile.boardPos), NSStringFromCGPoint(tile.unit.position));
    NSLog(@"%@",tile.unit);
    [self.gameLayer addChild:tile.unit z:SPRITES_TOP];
    [self reorderTile:tile];
}

- (MatchObject *) battleBrainNeedsMatchObj
{
    return self.matchObj;
}

- (void) battleBrainWantsToReorder:(Tile *)tile
{
    [self reorderTile:tile];
}

- (void) battleBrainWantsToDisplayInfo:(Unit *)unit
{
}

- (void) battleBrainWantsToDisplayChild:(CCNode *)child
{
    [self.gameLayer addChild:child z:EFFECTS];
}

- (BOOL) battleBrainWishesToPerform:(UnitSkill *)obj
{
    return [self.me canCastMana:obj.manaCost cmd:obj.cpCost];
}

- (void) battleBrainDidPerform:(UnitSkill *)obj
{
    [self.me castMana:obj.manaCost cmd:obj.cpCost];
}

/*
- (void) passPressed
{
    if ( isMyTurn ) {
        NSLog(@">[MYLOG]    Passing the turn!");
        [self.brain resetTurnForSide:isMyTurn];
        
        [[self.selection unit] toggleMenu:NO];
        [self.selection.unit.sprite stopAllActions];
        [self reset:!isMyTurn];
        [self reset:!isMyTurn];
        //[self sendEndTurn];
    }
}

- (void) reset:(bool)myTurn
{
    // State variables
    unitLocked = NO;
    isMyTurn = myTurn;
    isTurnA = myTurn;
    isTurnB = NO;
    isTurnC = NO;
    self.selection = nil;
    self.currentSkill = nil;
    
    [self displayTurnMessage:myTurn];
}

- (void) displayTurnMessage:(BOOL)myTurn
{
    //used in determining how long the slide/fade lasts
    float slideDuration = 0.5f;
    float delayDuration = 1.5f;
    
    //used in determining how far up/down along Y the label changes
    //positive = UP, negative = DOWN
    float yChange = 0;
    
    //used in determining how far left/right along the X the label changes
    //positive = RIGHT, negative = LEFT
    float xChange = 340;
    
    //set up the label
    NSString *message;
    if ( myTurn ) message = @"Your Turn!!";
    else message = @"Opponent's Turn!!";
    
    CCLabelBMFont *lblMessage = [CCLabelBMFont labelWithString:message fntFile:@"emulator.fnt"];
    
    //position the label where you want it...
    lblMessage.position = ccp(-100,240);
    
    //add the LABEL to the screen
    [self.hudLayer addChild:lblMessage z:DISPLAYS];
    
    id waitHere = [CCDelayTime actionWithDuration:delayDuration];
    id slideTwo = [CCMoveBy actionWithDuration:slideDuration position:ccp(xChange, yChange)];
    
    //run the actions on the LABEL
    [lblMessage runAction:waitHere];
    [lblMessage runAction:slideTwo];
    
    //the waiting for the slide/fade to complete
    id waitForSlide = [CCDelayTime actionWithDuration:delayDuration];
    id removeLabel = [CCCallBlock actionWithBlock:^{
        [self.hudLayer removeChild:lblMessage cleanup:YES];
        isMyTurn = myTurn;
    }];
    id sequence = [CCSequence actions:waitForSlide, removeLabel, nil];
    
    //actually run the sequence
    [self runAction:sequence];
}


#pragma mark - Net Handlers

- (void) sendDatafrom:(CGPoint)boardPos to:(CGPoint)p timeDuration:(int)time targets:(SFSObject *)targets
{
    return;
    NSLog(@">[MYLOG]    Sending data: \
          \n>           From: %@ \
          \n            To: %@ \
          \n            For Action: x and Duration: %d \
          \n            Effect: %@",
          NSStringFromCGPoint(boardPos),
          NSStringFromCGPoint(p),
          time,
          [targets description] );

    SFSObject *obj = [SFSObject newInstance];
    [obj putInt:@"xBoard" value:boardPos.x];
    [obj putInt:@"yBoard" value:boardPos.y];
    [obj putInt:@"xPos" value:p.x];
    [obj putInt:@"yPos" value:p.y];
    //[obj putInt:@"action" value:currentAction];
    [obj putSFSObject:@"effect" value:targets];
    [obj putSFSObject:@"null test" value:nil];
    [obj putInt:@"timeDuration" value:time];
    //[obj putClass:@"vector" value:self.vector];
    
    // Send the message, targetRoom is nil due to default being last joined room
    [smartFox send:[PublicMessageRequest requestWithMessage:@"gameAction" params:obj targetRoom:nil]];
}

- (void) sendEndTurn:(int)direction;
{
    [self passPressed];
    
    SFSObject *obj = [SFSObject newInstance];
    [obj putInt:@"direction" value:direction];
    [smartFox send:[PublicMessageRequest requestWithMessage:@"endTurn" params:obj targetRoom:nil]];
}

- (void) onPublicMessage:(SFSEvent *)evt
{
    SFSUser *sender = [evt.params objectForKey:@"sender"];
    NSString *message = [evt.params objectForKey:@"message"];
    SFSObject *data = [evt.params objectForKey:@"data"];
    NSLog(@">[MYLOG]    Received a public message from %@",sender.name);
    if ([sender.name isEqual:smartFox.mySelf.name]) {
        [self passPressed];
        return;
    } else {
        NSLog(@">>>>>>>>>>> %@", message);
        if ( [message isEqual:@"endTurn"]) {
            [self passPressed];
        } else if ( [message isEqual:@"gameAction"] ) {
            
            [self.brain doOppAction:data];
        }
    }
}*/
@end