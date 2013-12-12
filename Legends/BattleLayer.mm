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
        [self addChild:_gameLayer z:GAMELAYER];
        
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:HUDLAYER];
        
        [self initMap];
        [self initTemp];
        
        _brain = [[BattleBrain alloc] initWithMap:_tmxLayer delegate:self];
        
        if ( [_matchObj.myUser isItMe] ) {
            turnState = TurnStateA;
        }
            
        
//        [self createMap];
//        [self createUI];
//        [self createMenu];
//
//        if ( [[UserSingleton get] amIPlayerOne] ) {
//            [self reset:YES];
//            CCLOG(@"MYLOG:  I AM PLAYER 1");
//            
//        } else {
//            [self reset:NO];
//            CCLOG(@"MYLOG:  I AM PLAYER 2");
//            
//        }
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
        
//        [self.brain turn_driver:position];
        [self animTest:position];
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

- (void) battleBrainWantsToDisplayChild:(CCNode *)child at:(CGPoint)boardPos
{
    int pos = boardPos.x + boardPos.y;
    [self.gameLayer addChild:child z:SPRITES_TOP - pos];
}
/*
- (void) createMap
{
    // Tile map
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"basic_tactics_v2.tmx"];
    _map.position = CGPointMake(-45,-45);
    _map.scale = MAPSCALE;
    _tmxLayer = [_map layerNamed:@"layer"];
    [_gameLayer addChild:_map z:MAP];
}

- (void) createUI
{
    // Setup Display
    _display = [UnitDisplay displayWithPosition:ccp(85,265)];
    [_hudLayer addChild:_display z:DISPLAYS];
}

- (void) createMenu
{
//    [CCMenuItemFont setFontSize:20];
//    CCMenuItem *nw = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_NW_temp.png"]
//                                             selectedSprite:[CCSprite spriteWithFile:@"turn_NW_selected.png"]
//                                                     target:self
//                                                   selector:@selector(turnPressed:)];
//    nw.tag = NW; nw.position = ccp(-HALFLENGTH,HALFWIDTH);
//    CCMenuItem *ne = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_NE_temp.png"]
//                                             selectedSprite:[CCSprite spriteWithFile:@"turn_NE_selected.png"]
//                                                     target:self
//                                                   selector:@selector(turnPressed:)];
//    ne.tag = NE; ne.position = ccp(HALFLENGTH,HALFWIDTH);
//    CCMenuItem *se = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_SE_temp.png"]
//                                             selectedSprite:[CCSprite spriteWithFile:@"turn_SE_selected.png"]
//                                                     target:self
//                                                   selector:@selector(turnPressed:)];
//    se.tag = SE; se.position = ccp(HALFLENGTH,-HALFWIDTH);
//    CCMenuItem *sw = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_SW_temp.png"]
//                                             selectedSprite:[CCSprite spriteWithFile:@"turn_SW_selected.png"]
//                                                     target:self
//                                                   selector:@selector(turnPressed:)];
//    sw.tag = SW; sw.position = ccp(-HALFLENGTH,-HALFWIDTH);
    
//    _turnMenu = [CCMenu menuWithItems:nw,ne,se,sw, nil];
//    _turnMenu.visible = NO;
//    [_gameLayer addChild:_turnMenu z:MENUS];
    
    // Old menu
    _menu = [CCMenu menuWithItems:nil];
    _menu.position = ccp(425,40);
    _menu.visible = YES;
    [_hudLayer addChild:_menu z:MENUS];
}

#pragma mark - Touch Handlers
- (void) turnPressed:(CCMenuItem *)sender
{
    NSLog(@">[NSLog] turnPressed with tag:%d",sender.tag);
    //self.selection.unit.direction = sender.tag;
    self.turnMenu.visible = NO;
    //[self sendEndTurn:sender.tag];
    [self passPressed];
}



#pragma mark - Main Turn Drivers
- (void) offTurn_drive:(CGPoint)position
{
    NSLog(@">[NOTICE] Not your turn, can only do some things");
    
    [self setSelection:[self.brain doSelect:position]];
    [self.display setDisplayFor:[self selection]];
}


- (void) turn_drive:(CGPoint)position
{
    NSAssert3((isTurnA + isTurnB + isTurnC < 2),
             @">[FATAL] TWO POSSIBLE TURN STATES FOUND:%d%d%d",
              isTurnA, isTurnB, isTurnC);
    if ( isTurnA ) {
        [self turnA:position];
    } else if ( isTurnB ) {
        [self turnB:position];
    } else if ( isTurnC ) {
        [self turnC:position];
    }
}

- (void) turnA:(CGPoint)position
{
    CCLOG(@"\n==================TURN PHASE A: Make a selection==================\n");
    
    // Set selection and display
    Tile *temp = [self.brain doSelect:position];
    [self.display setDisplayFor:temp];
    if ( !unitLocked )  [self setSelection:temp];
    
    if ( temp.unit != nil ) {
        [self center:temp.unit.sprite.position];
        if ( ![self.selection.unit isEqual:temp.unit] ) return;

        [self.selection.unit.sprite stopActionByTag:IDLETAG];
        if ( [[self selection] isOwned] && ![self.selection.unit.sprite numberOfRunningActions]) {
            // Show visual selection
            [self.selection.unit secondaryAction:ActionIdle at:CGPointZero];
            
            // Open the menu and set flag
            [[[self selection] unit] toggleMenu:YES];
            
            // Go to turn B next click
            NSLog(@">[MYLOG] Proceed to B next\n");
            isTurnA = NO;
            isTurnB = YES;
        }
    }
}

- (void) turnB:(CGPoint)position
{
    CCLOG(@"\n==================TURN PHASE B: Confirm the action==================\n");

    [self highLightMode:HighlightModeOff skill:nil params:nil];
    CGPoint target = [[self brain] findBrdPos:position];
    ccColor3B temp = ccWHITE;
    if ( [self.brain isValidTile:target] )
        temp = [[self tmxLayer] tileAt:ccp(MAPLENGTH-1-target.x, MAPWIDTH-1-target.y)].color;

    if ( ![GeneralUtils ccColor3BCompare:temp :ccWHITE] ) {

        NSMutableArray *tempArray = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:target]];
        [self highLightMode:HighlightModeEffect
                      skill:self.currentSkill
                     params:[NSMutableArray arrayWithObject:tempArray]];
        self.vector = [TileVector vectorWithTile:[self.brain findTile:target absPos:NO]
                                       direction:direction];
        // Go to turn D next click
        NSLog(@">[MYLOG] Proceed to C next\n");
        isTurnB = NO;
        isTurnC = YES;
        
    } else {
        self.currentSkill = nil;
        
        [[[[self selection] unit] sprite] stopActionByTag:IDLETAG];
        
        [self.display setDisplayFor:nil];
        [[[self selection] unit] toggleMenu:NO];
        
        // Go to turn A immediately
        NSLog(@">[MYLOG] Proceed to A immediately\n");
        isTurnB = NO;
        isTurnA = YES;
        
        [self turnA:position];
    }
}

- (void) turnC:(CGPoint)position
{
    CCLOG(@"\n==================TURN PHASE C: Perform an action==================\n");
    
    // Find the target to compare with the confirming
    CGPoint target = [[self brain] findBrdPos:position];
    ccColor3B temp = ccWHITE;
    if ( [self.brain isValidTile:target] )
        temp = [[self tmxLayer] tileAt:ccp(MAPLENGTH-1-target.x, MAPWIDTH-1-target.y)].color;
    
    SFSObject *obj = [SFSObject newInstance];
    [self highLightMode:HighlightModeOff skill:nil params:nil];
    
    if ( ![GeneralUtils ccColor3BCompare:temp :ccWHITE] &&
          [self.brain doAction:currentAction
                           for:self.selection
                        toward:self.vector
                       oppData:obj
                       targets:self.boardTargets] )
    {
        if ( self.currentSkill.skillType == ActionMove
            || self.currentSkill.skillType == ActionTeleport ) {
            // reorder child
            self.selection = self.vector.tile;
            [self reorderTile:[self selection]];
        }
             
        CGPoint oldPos = [[self selection] boardPos];
        unitLocked = YES;
        self.currentSkill = nil;
        
        // Send data
        [self sendDatafrom:oldPos to:position timeDuration:0 targets:obj];
        
        if ( [self.selection.unit hasActionLeft] ) {
            NSLog(@">[MYLOG] Proceed to turn B next");
            isTurnC = NO;
            isTurnB = YES;
        }
    } else {
        [[[[self selection] unit] sprite] stopActionByTag:IDLETAG];
        self.currentSkill = nil;
        [self.display setDisplayFor:nil];
        [[[self selection] unit] toggleMenu:NO];
        
        // Go to turn A immediately
        NSLog(@">[MYLOG] Proceed to A immediately\n");
        isTurnC = NO;
        isTurnA = YES;
        
        [self turnA:position];
    }
}

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
}

#pragma mark - Helpers
- (void) tint:(CCSprite *)sprite with:(ccColor3B)color by:(int)factor
{
    BOOL isRed = NO;
    BOOL isGreen = NO;
    BOOL isBlue = NO;
    
    if ( color.r == MAX(MAX(color.r,color.g),color.b) ) isRed = YES;
    else if ( color.g == MAX(color.g,color.b)) isGreen = YES;
    else isBlue = YES;

    id tintUp = [CCTintTo actionWithDuration:0.5
                                         red:MIN(color.r+isRed*factor,255)
                                       green:MIN(color.g+isGreen*factor,255)
                                        blue:MIN(color.b+isBlue*factor,255)
                 ];
    id tintDown = [CCTintTo actionWithDuration:0.5
                                           red:MAX(color.r-isRed*factor,0)
                                         green:MAX(color.g-isBlue*factor,0)
                                          blue:MAX(color.b-isGreen*factor,0)
                   ];
    id sequence = [CCSequence actionOne:tintUp two:tintDown];
    
    [sprite runAction:[CCRepeatForever actionWithAction:sequence]];
}

- (void) center:(CGPoint)position
{
    CGPoint difference = ccpSub(position, ccpSub(ccp(200,150),self.gameLayer.position) );
    CGPoint destination = ccp(self.gameLayer.position.x - difference.x,
                              self.gameLayer.position.y - difference.y);
    
    if ( destination.x > MAX_SCROLL_X )
        destination.x = MAX_SCROLL_X ;
    if ( destination.y > MAX_SCROLL_Y )
        destination.y = MAX_SCROLL_Y ;
    if ( destination.x < MIN_SCROLL_X )
        destination.x = MIN_SCROLL_X ;
    if ( destination.y < MIN_SCROLL_Y )
        destination.y = MIN_SCROLL_Y ;
    
    [self.gameLayer runAction:[CCMoveTo actionWithDuration:0.5 position:destination]];
    [self.brain setCurrentLayerPos:destination];
}



- (void) highLightMode:(HighlightMode)mode skill:(SkillObj *)skill params:(NSMutableArray *)params
{
    NSLog(@">[MYLOG]        BattleLayer::highlight is centering around %@ %d", [self selection], mode);
    
    //[self.display setDisplayFor:self.selection]; //?
    ccColor3B colour = [GeneralUtils colorFromAction:skill.skillType];
    NSMutableArray *cgpointPtr;
    
    if ( mode == HighlightModeRange )
    {
        if ( skill.skillType == ActionMove || skill.skillType == ActionTeleport ) {
            cgpointPtr = [self.brain findMoveTiles:self.selection.boardPos
                                                      for:((MoveSkillObj *)skill).moveSkillRange];
        } else {
            cgpointPtr = skill.skillRange;
        }
        
        for ( NSValue *v in cgpointPtr ) {
            CGPoint pos = ccpAdd (self.selection.boardPos,[v CGPointValue] );
            if ( [self.brain isValidTile:pos] ) {
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:colour];
            }
            [self.boardTargets addObject:[NSValue valueWithCGPoint:pos]];
        }
    }
    else if ( mode == HighlightModeEffect )
    {
        [skill getSkillEffectForTarget:[[params objectAtIndex:0] CGPointValue]];
        cgpointPtr = skill.skillRange;
        
        for (NSValue *v in self.boardTargets) {
            CGPoint pos = ccpAdd (self.selection.boardPos,[v CGPointValue] );
            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:colour];
                [self tint:temp with:temp.color by:75];
            }
            [self.boardTargets addObject:[NSValue valueWithCGPoint:pos]];
        }
    }
    else if ( mode == HighlightModeOff )
    {
        NSAssert( self.boardTargets == nil, @"FATAL BOARDTARGETS NIL");        
        for ( NSValue *v in self.boardTargets ) {
            CGPoint pos = [v CGPointValue];
            if ([self.brain isValidTile:pos]) {
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:ccWHITE];
                [temp stopAllActions];
            }
        }
        self.boardTargets = nil;
    }
}

#pragma mark - Unit Delegates
- (BOOL) unitDelegatePressedSkill:(SkillObj *)skill
{
    NSLog(@">[MYLOG]    Received action %d",skill.skillType);
    isTurnA = NO;
    isTurnB = YES;
    isTurnC = NO;
    [self highLightMode:HighlightModeRange skill:skill params:nil];
}

- (void) unitDelegateKillMe:(Unit *)unit at:(CGPoint)position
{
    [self.gameLayer removeChild:unit.spriteSheet cleanup:YES];
    [self.gameLayer removeChild:unit.menu cleanup:YES];
    [self.brain killtile:position];
}

- (void) unitDelegateAddSprite:(CCSprite *)sprite z:(ZORDER)z
{
    [self.gameLayer addChild:sprite z:z];
}

- (void) unitDelegateRemoveSprite:(CCSprite *)sprite
{
    [self.gameLayer removeChild:sprite cleanup:YES];
}

- (void) unitDelegateUnit:(Unit *)unit finishedAction:(Action)action
{
    [self center:unit.sprite.position];
    [self.display setDisplayFor:self.selection];
    if ( ![unit hasActionLeft] ) {
        self.turnMenu.visible = YES;
        self.turnMenu.position = unit.sprite.position;
    }
    //[self.brain actionDidFinish];
}

- (void) unitDelegateShakeScreen
{
    CCAction *shake = [CCSequence actions:
                       [CCShake actionWithDuration:0.75 amplitude:ccp(20,20) dampening:YES], nil];
    shake.tag = 10;
    [self.gameLayer runAction:shake];
}

- (void) unitDelegateDisplayCombatMessage:(NSMutableString *)message
                               atPosition:(CGPoint)point
                                withColor:(ccColor3B)color
                                   isCrit:(BOOL)isCrit
{
    NSLog(@">[MYLOG]        Displaying %@, at [%f,%f]",message,point.x,point.y);
    float slideDuration = 0.6; float fadeDuration = 2;
    float yChange = 35;
    float xChange = 0;
    
    //set up the label
    if (isCrit) [message appendString:@"!!!"];
    CCLabelBMFont *lblMessage = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    lblMessage.color = color;
    lblMessage.position = ccp(point.x,point.y+25);
    [self addChild:lblMessage z:DISPLAYS];
    
    id slideUp = [CCMoveBy actionWithDuration:slideDuration
                                     position:ccp(xChange,yChange)];
    id fadeOut = [CCFadeOut actionWithDuration:fadeDuration];
    id text = [CCSequence actions:slideUp, fadeOut, nil];
    [lblMessage runAction:text];
    
    id waitForSlide = [CCDelayTime actionWithDuration:slideDuration + fadeDuration];
    id removeLabel = [CCCallBlock actionWithBlock:^{
        [self removeChild:lblMessage cleanup:YES];
    }];
    id sequence = [CCSequence actions:waitForSlide, removeLabel, nil];
    
    //actually run the sequence
    [self runAction:sequence];
}

- (void) unitDelegateUnit:(Unit *)unit updateLayer:(CGPoint)boardPos
{
    int pos = boardPos.x + boardPos.y;
    [self.gameLayer reorderChild:[unit spriteSheet] z:SPRITES_TOP - pos];
}

#pragma mark - Brain Delegates
- (void) battleBrainDelegateLoadTile:(Tile *)tile
{
    [tile.unit setPosition:[self.brain findAbsPos:tile.boardPos]];
    [[tile unit] setDelegate:self];
    [self.gameLayer addChild:tile.unit z:SPRITES_TOP];
    [self reorderTile:tile];
    if (tile.isOwned) [self.gameLayer addChild:tile.unit.menu z:MENUS];
}

- (void) battleBrainDelegateTransformTileAt:(CGPoint)position fromGid:(int)start toGid:(int)end delay:(int)delay
{
    CGPoint adjustPos = ccp(MAPLENGTH-1-position.x,MAPWIDTH-1-position.y);
    NSLog(@"%@ %d %d %d,",NSStringFromCGPoint(position),start,end,delay);
    __block int begin = start;
    __block int sign = (end - start)/abs(end - start);
    CCSprite *target = [self.tmxLayer tileAt:adjustPos];
    
    id initialDelay = [CCDelayTime actionWithDuration:delay];
    id betweenDelay = [CCDelayTime actionWithDuration:0.1];
    id shift = [CCCallBlock actionWithBlock:^{
        [self.tmxLayer setTileGID:begin at:adjustPos];
        begin = begin + sign;
    }];
    id repeat = [CCRepeat actionWithAction:[CCSequence actions:shift, betweenDelay, nil]
                                     times:end-start];
    
    [target runAction:[CCSequence actions:initialDelay, repeat, nil]];
}

- (void) animateTileAt:(CGPoint)position with:(CCAction *)action
{
    
}*/
@end