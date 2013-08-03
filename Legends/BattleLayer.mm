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
@property (nonatomic, strong) CCLabelBMFont *debug;
@property (nonatomic, strong) NSArray *highlightPtr;
@property (nonatomic, strong) TileVector *vector;
@end

@implementation BattleLayer
@synthesize map = _map;
@synthesize tmxLayer = _tmxLayer, gameLayer = _gameLayer, hudLayer = _hudLayer;
@synthesize selection = _selection, display = _display, menu = _menu;
// private
@synthesize brain = _brain, debug = _debug;

#pragma mark - Setters n Getters
- (void) setSelection:(Tile *)selection
{
    if ( _selection != nil && selection == nil )
        [_selection.unit.sprite stopActionByTag:IDLETAG];
    _selection = selection;
}

#pragma mark - Init n Class
+(CCScene *) scene
{
    CCLOG(@"=========================<ENTERING BattleLayer>=========================");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BattleLayer *layer = [BattleLayer node];
    layer.tag = kTagBattleLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    if ( (self=[super init]) )
    {
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        isTouchEnabled_ = YES;
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        
        // Game Layer
        _gameLayer = [CCLayer node];
        [self addChild:_gameLayer z:GAMELAYER];
        
        // Hud Layer
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:HUDLAYER];
        
        [self createMap];
        [self createUI];
        [self createMenu];
        
        // Setup Brain
        _brain = [[BattleBrain alloc] initWithMap:_tmxLayer];
        [_brain setDelegate:self];
        [_brain restoreSetup];

        if ( [[UserSingleton get] amIPlayerOne] ) {
            [self reset:YES];
            CCLOG(@"MYLOG:  I AM PLAYER 1");
            
        } else {
            [self reset:NO];
            CCLOG(@"MYLOG:  I AM PLAYER 2");
            
        }
    }
    return self;
}

- (void) createMap
{
    // Tile map
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"basic_tactics_v2.tmx"];
    _map.position = CGPointMake(-45,-45);
    _map.scale = MAPSCALE;
    _tmxLayer = [_map layerNamed:@"layer"];
    [_gameLayer addChild:_map z:MAPS];
}

- (void) createUI
{
    // Setup Display
    _display = [UnitDisplay displayWithPosition:ccp(85,265)];
    [_hudLayer addChild:_display z:DISPLAYS];
}

- (void) createMenu
{
    [CCMenuItemFont setFontSize:20];
    CCMenuItem *nw = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_NW_temp.png"]
                                             selectedSprite:[CCSprite spriteWithFile:@"turn_NW_selected.png"]
                                                     target:self
                                                   selector:@selector(turnPressed:)];
    nw.tag = NW; nw.position = ccp(-HALFLENGTH,HALFWIDTH);
    CCMenuItem *ne = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_NE_temp.png"]
                                             selectedSprite:[CCSprite spriteWithFile:@"turn_NE_selected.png"]
                                                     target:self
                                                   selector:@selector(turnPressed:)];
    ne.tag = NE; ne.position = ccp(HALFLENGTH,HALFWIDTH);
    CCMenuItem *se = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_SE_temp.png"]
                                             selectedSprite:[CCSprite spriteWithFile:@"turn_SE_selected.png"]
                                                     target:self
                                                   selector:@selector(turnPressed:)];
    se.tag = SE; se.position = ccp(HALFLENGTH,-HALFWIDTH);
    CCMenuItem *sw = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"turn_SW_temp.png"]
                                             selectedSprite:[CCSprite spriteWithFile:@"turn_SW_selected.png"]
                                                     target:self
                                                   selector:@selector(turnPressed:)];
    sw.tag = SW; sw.position = ccp(-HALFLENGTH,-HALFWIDTH);
    
    _turnMenu = [CCMenu menuWithItems:nw,ne,se,sw, nil];
    _turnMenu.visible = NO;
    [_gameLayer addChild:_turnMenu z:MENUS];
    
    // Old menu
    _menu = [CCMenu menuWithItems:nil];
    _menu.position = ccp(425,40);
    _menu.visible = YES;
    [_hudLayer addChild:_menu z:MENUS];
    
    _debug = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
    _debug.position = ccp(440,25);
    _debug.scale = 0.65;
    [_hudLayer addChild:_debug];
}

#pragma mark - Touch Handlers
- (void) turnPressed:(CCMenuItem *)sender
{
    NSLog(@">[NSLog] turnPressed with tag:%d",sender.tag);
    self.selection.unit.direction = sender.tag;
    self.turnMenu.visible = NO;
    //[self sendEndTurn:sender.tag];
    [self passPressed];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Do nothing atm
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
        scrolled = YES;
        
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
        [self.brain setCurrentLayerPos:pos];
        
        //NSLog(@"New pos is %f %f",pos.x,pos.y);
        
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
        
        [self.debug setString:[NSString stringWithFormat:@"%d, %d", (int)position.x, (int)position.y]];
        
        //NSLog(@"%@",NSStringFromCGPoint(position));
        
        if (isMyTurn)
            [self turn_drive:position];
        else
            [self offTurn_drive:position];
    }
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
            [[[self selection] unit] action:IDLE at:CGPointZero];
            
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
    
    CGPoint target = [[self brain] findBrdPos:position];
    ccColor3B temp = ccWHITE;
    if ( [self.brain isValidTile:target] )
        temp = [[self tmxLayer] tileAt:ccp(MAPLENGTH-1-target.x, MAPWIDTH-1-target.y)].color;

    if ( ![self isccColor3B:temp theSame:ccWHITE] ) {
        [self highlightArea:NO];
        // Direction
        int direction = [self directionFrom:target to:self.selection.boardPos];
        [self highLightEffect:YES toward:direction at:target];
        self.vector = [TileVector vectorWithTile:[self.brain findTile:target absPos:NO]
                                       direction:direction];
        // Go to turn D next click
        NSLog(@">[MYLOG] Proceed to C next\n");
        isTurnB = NO;
        isTurnC = YES;
        
    } else {
        if ( currentAction != UNKNOWN ) {
            [self highlightArea:NO];
            currentAction = UNKNOWN;
        }
        
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
    [self highLightEffect:NO toward:-1 at:CGPointZero];
    
    if ( ![self isccColor3B:temp theSame:ccWHITE] && [[self brain] doAction:currentAction for:[self selection]
                                                                     toward:self.vector
                                                                     oppObj:obj
                                                                    targets:self.highlightPtr] )
    {
        if ( currentAction == MOVE || currentAction == TELEPORT_MOVE ) {
            // reorder child
            self.selection = self.vector.tile;
            [self reorderTile:[self selection]];
        }
             
        CGPoint oldPos = [[self selection] boardPos];
        unitLocked = YES;
        currentAction = UNKNOWN;
             
        // Send data
        [self sendDatafrom:oldPos to:position timeDuration:0 targets:obj];
        
        if ( [self.selection.unit hasActionLeft] ) {
            NSLog(@">[MYLOG] Proceed to turn B next");
            isTurnC = NO;
            isTurnB = YES;
        }
    } else {
        [[[[self selection] unit] sprite] stopActionByTag:IDLETAG];
        currentAction = UNKNOWN;
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
    currentAction = UNKNOWN;
    unitLocked = NO;
    isMyTurn = myTurn;
    isTurnA = myTurn;
    isTurnB = NO;
    isTurnC = NO;
    self.selection = nil;
    
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
          \n            For Action: %d and Duration: %d \
          \n            Effect: %@",
          NSStringFromCGPoint(boardPos),
          NSStringFromCGPoint(p),
          currentAction, time,
          [targets description] );

    SFSObject *obj = [SFSObject newInstance];
    [obj putInt:@"xBoard" value:boardPos.x];
    [obj putInt:@"yBoard" value:boardPos.y];
    [obj putInt:@"xPos" value:p.x];
    [obj putInt:@"yPos" value:p.y];
    [obj putInt:@"action" value:currentAction];
    [obj putSFSObject:@"effect" value:targets];
    [obj putSFSObject:@"null test" value:nil];
    [obj putInt:@"timeDuration" value:time];
    [obj putClass:@"vector" value:self.vector];
    
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
- (DIRECTION) directionFrom:(CGPoint)start to:(CGPoint)end
{
    CGPoint difference = ccpSub(start, end);
    if (difference.x > 0 ) return NW;
    else if (difference.x < 0 ) return SE;
    else if (difference.y > 0 ) return NE;
    else if (difference.y < 0 ) return SW;
    else return NE;
}

- (BOOL)isccColor3B:(ccColor3B)color1 theSame:(ccColor3B)color2
{
    if ((color1.r == color2.r) && (color1.g == color2.g) && (color1.b == color2.b)){
        return YES;
    } else {
        return NO;
    }
}

- (ccColor3B)darkenColor3B:(ccColor3B) color by:(float)factor
{
    return {color.r*factor, color.g*factor, color.b*factor};
}

- (ccColor3B) colorFromAction:(int)action
{
    ccColor3B colour;
    // Find the colour to highlight ground
    switch ( action ) {
        case MOVE: colour = ccDODGERBLUE;
            break;
        case ATTK: colour = ccORANGE;
            break;
        case HEAL_ALL: colour = ccGREEN;
            break;
        case GORGON_SHOOT: colour = ccORANGE;
            break;
        case GORGON_FREEZE: colour = ccDARKCYAN;
            break;
        case TELEPORT_MOVE: colour = ccDODGERBLUE;
            break;
        case MUDGOLEM_EARTHQUAKE: colour = ccORANGE;
            break;
        case DRAGON_FIREBALL: colour = ccORANGE;
            break;
        case DRAGON_FLAMEBREATH: colour = ccORANGERED;
            break;
        default: CCLOG(@"Error! Unknown action occurred: %d", action);
            break;
    }
    return colour;
}

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

- (void) reorderTile:(Tile *)tile
{
    int pos = tile.boardPos.x + tile.boardPos.y;
    [self.gameLayer reorderChild:[[tile unit] spriteSheet] z:SPRITES_TOP - pos];
}

- (void) highlightArea:(BOOL)highlight
{
    NSLog(@">[MYLOG]        BattleLayer::highlightArea is centering around %@ [%d]",
          [self selection], highlight );
    
    [self.display setDisplayFor:self.selection];
    int action = currentAction;
    ccColor3B colour = [self colorFromAction:action];
    
    NSArray *highlights = [[self brain] findActionTiles:[self selection] action:action];

    if ( highlight ) {
        for (NSValue *v in highlights) {
            CGPoint pos = [v CGPointValue];

            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:colour];
            }
        }
    } else {
        for (NSValue *v in highlights) {
            CGPoint pos = [v CGPointValue];
            
            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:ccWHITE];
            }
        }
    }
}

- (void) highLightEffect:(BOOL)highlight toward:(int)direction at:(CGPoint)position
{
    NSLog(@">[MYLOG]        BattleLayer::highlightEffect is centering around %@ direction %d",
          [self selection], direction );
    
    [self.display setDisplayFor:self.selection];
    int action = currentAction;
    ccColor3B colour = [self colorFromAction:action];
    colour = [self darkenColor3B:colour by:0.8];
    if ( highlight )
        self.highlightPtr = [[self brain] findEffectTiles:[self selection] action:action direction:direction center:position];

    if ( highlight ) {
        for (NSValue *v in self.highlightPtr) {
            CGPoint pos = [v CGPointValue];
            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:colour];
                [self tint:temp with:temp.color by:75];
            }
        }
    } else {
        for (NSValue *v in self.highlightPtr) {
            CGPoint pos = [v CGPointValue];
            
            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:ccWHITE];
                [temp stopAllActions];
            }
        }
    }
}

#pragma mark - Unit Delegates
- (BOOL) pressedButton:(int)action
{
    NSLog(@">[MYLOG]    Received action %d",action);
    isTurnA = NO;
    isTurnB = YES;
    isTurnC = NO;
    
    if ( action == MOVE ) {
        currentAction = MOVE;
        [self highlightArea:true];
        
    } else if ( action == ATTK ) {
        currentAction = ATTK;
        [self highlightArea:true];
        
    } else if ( action == DEFN ) {
        currentAction = DEFN;
        [self highlightArea:true];
        
    } else {
        currentAction = action;
        [self highlightArea:YES];
        
    }
    return YES;
}

- (void)killMe:(Unit *)unit at:(CGPoint)position;
{
    [self.gameLayer removeChild:unit.spriteSheet cleanup:YES];
    [self.gameLayer removeChild:unit.menu cleanup:YES];
    [self.brain killtile:position];
}

- (void) addSprite:(CCSprite *)sprite z:(int)z
{
    [self.gameLayer addChild:sprite z:z];
}

- (void) removeSprite:(CCSprite *)sprite
{
    [self.gameLayer removeChild:sprite cleanup:YES];
}

- (void) removeByTag:(int)tag
{
    [self.gameLayer removeChildByTag:tag cleanup:YES];
}

- (void) actionDidFinish:(Unit *)unit
{
    [self center:unit.sprite.position];
    [self.display setDisplayFor:self.selection];
    if ( ![unit hasActionLeft] ) {
        self.turnMenu.visible = YES;
        self.turnMenu.position = unit.sprite.position;
    }
    [self.brain actionDidFinish];
}

- (void) shakeScreenAfter:(float)delay
{
    CCAction *shake = [CCSequence actions:
                       [CCDelayTime actionWithDuration:delay],
                       [CCShake actionWithDuration:0.75 amplitude:ccp(20,20) dampening:YES], nil];
    shake.tag = 10;
    [self.gameLayer runAction:shake];
}

- (void)    displayCombatMessage:(NSString*)message
                      atPosition:(CGPoint)point
                       withColor:(ccColor3B)color
{
    NSLog(@">[MYLOG]        Displaying %@, at [%f,%f]",message,point.x,point.y);
    //used in determining how long the slide/fade lasts
    float slideDuration = 4;
    
    //used in determining how far up/down along Y the label changes
    //positive = UP, negative = DOWN
    float yChange = 50;
    
    //used in determining how far left/right along the X the label changes
    //positive = RIGHT, negative = LEFT
    float xChange = 0;
    
    //set up the label
    CCLabelBMFont *lblMessage = [CCLabelBMFont labelWithString:message fntFile:COMBATFONTBIG];
    
    //Change the color
    lblMessage.color = color;
    
    //position the label where you want it...
    lblMessage.position = ccp(point.x,point.y+50);
    
    //add the LABEL to the screen
    [self.gameLayer addChild:lblMessage z:DISPLAYS];
    
    id slideUp = [CCMoveBy actionWithDuration:slideDuration position:ccp(xChange,yChange)];
    id fadeOut = [CCFadeOut actionWithDuration:slideDuration];
    
    //run the actions on the LABEL
    id text = [CCSpawn actions:fadeOut, slideUp, nil];
    [lblMessage runAction:text];
    
    //the waiting for the slide/fade to complete
    id waitForSlide = [CCDelayTime actionWithDuration:slideDuration];
    
    //the actual removal of the label (uses a block so all the code stays here)
    id removeLabel = [CCCallBlock actionWithBlock:^{
        [self.gameLayer removeChild:lblMessage cleanup:YES];
    }];
    
    //sequence them together so they happen IN ORDER (not at once)
    id sequence = [CCSequence actions:waitForSlide, removeLabel, nil];
    
    //actually run the sequence
    [self runAction:sequence];
}

#pragma mark - Brain Delegates
- (void)loadTile:(Tile *)tile
{
    [[[tile unit] sprite] setPosition:[self.brain findAbsPos:tile.boardPos]];
    [[tile unit] setDelegate:self];
    [self.gameLayer addChild:[[tile unit] spriteSheet] z:SPRITES_TOP];
    [self reorderTile:tile];
    if (tile.isOwned) [self.gameLayer addChild:[[tile unit] menu] z:MENUS];
}

- (void)failToLoad
{
    [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
}

- (void)unitDidMoveTo:(Tile *)tile
{
    [self setSelection:tile];
}

- (void) transformTileAt:(CGPoint)position fromGid:(int)start toGid:(int)end delay:(float)delay
{
    CGPoint adjustPos = ccp(MAPLENGTH-1-position.x,MAPWIDTH-1-position.y);
    NSLog(@"%@ %d %d %f,",NSStringFromCGPoint(position),start,end,delay);
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
    
}
@end