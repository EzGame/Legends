//
//  BattleLayer.m
//  Legends
//
//  Created by David Zhang on 2013-01-29.
//
//
#define DRAG_SCROLL_MULTIPLIER 0.25
#define PINCH_ZOOM_MULTIPLIER 0.003
#define MAX_ZOOM 1.1
#define MIN_ZOOM 0.375
#define MAX_SCROLL_X 25
#define MAX_SCROLL_Y 25
#define MIN_SCROLL_X -25
#define MIN_SCROLL_Y -50

#import "BattleLayer.h"
#import "MainMenuViewController.h"

@interface BattleLayer()
@property (nonatomic, strong) BattleBrain *brain;
@property (nonatomic, strong) NSArray *highlights;
@property (nonatomic, strong) CCLabelBMFont *debug;

@property (nonatomic, strong) CommandsDisplay *myCP;
@property (nonatomic, strong) CommandsDisplay *opCP;
- (void) reset:(bool)myTurn;
@end

@implementation BattleLayer
@synthesize map = _map;
@synthesize tmxLayer = _tmxLayer, gameLayer = _gameLayer, hudLayer = _hudLayer;
@synthesize selection = _selection, display = _display, menu = _menu;
// private
@synthesize brain = _brain, highlights = _highlights, debug = _debug;
@synthesize myCP = _myCP, opCP = _opCP;

// THIS IS THE CONTROLLER
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

- (void) reset:(bool)myTurn
{    
    // State variables
    currentAction = UNKNOWN;
    isMenuOpen = NO;
    costOfAction = 0;
    confirming = CGPointZero;
    [self setSelection:nil];
    [self displayTurnMessage:myTurn];
}

- (id)init
{
    if ( (self=[super init]) )
    {
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        isTouchEnabled_ = YES;
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        usedTiles = [[NSMutableArray alloc] init];
        
        // Game Layer
        _gameLayer = [CCLayer node];
        [self addChild:_gameLayer z:GAMELAYER];
        
        // Hud Layer
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:DISPLAYS];
        
        
        // Setup Brain
        _brain = [[BattleBrain alloc] initWithMap:_tmxLayer];
        [_brain setDelegate:self];
        [_brain restoreSetup];
        
        [self createMap];
        [self createUI];
        [self createMenu];
        
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
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"basic_tactics.tmx"];
    _map.position = CGPointMake(-45,-60);
    _map.scale = MAPSCALE;
    _tmxLayer = [_map layerNamed:@"layer"];
    [_gameLayer addChild:_map z:MAPS];
}
- (void) createUI
{
    // Setup Display
    _display = [UnitDisplay displayWithPosition:ccp(10,300)];
    [_display scale:0.7];
    [_hudLayer addChild:_display z:DISPLAYS];
    
    _myCP = [CommandsDisplay commandsDisplayWithPosition:ccp(10,10) amount:8 gain:4 for:YES];
    _opCP = [CommandsDisplay commandsDisplayWithPosition:ccp(470,310) amount:8 gain:4 for:NO];
    [_hudLayer addChild:_myCP z:DISPLAYS];
    [_hudLayer addChild:_opCP z:DISPLAYS];
}

- (void) createMenu
{
    // Change this shit
    [CCMenuItemFont setFontSize:20];
    CCMenuItem *startTurnButton = [CCMenuItemFont itemWithString:@"Chat"
                                                          target:self
                                                        selector:@selector(startTurnPressed)];
    
    CCMenuItem *endTurnButton = [CCMenuItemFont itemWithString:@"Surrender"
                                                        target:self
                                                      selector:@selector(endTurnPressed)];
    CCMenuItem *passButton = [CCMenuItemFont itemWithString:@"Pass"
                                                     target:self
                                                   selector:@selector(passPressed)];

    passButton.visible = YES;
    startTurnButton.visible = false;
    endTurnButton.visible = false;
    
    _menu = [CCMenu menuWithItems:startTurnButton, endTurnButton, passButton, nil];
    _menu.position = ccp(425,40);
    [_menu alignItemsVertically];
    _menu.visible = YES;
    [_hudLayer addChild:_menu z:MENUS];
    
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
        
        NSLog(@"New pos is %f %f",pos.x,pos.y);
        
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

        if (isMyTurn)
            [self turn_drive:position];
        else
            [self offTurn_drive:position];
    }
}

- (void) offTurn_drive:(CGPoint)position
{
    CCLOG(@"Not your turn, can only do some things");
    [self setSelection:[self.brain doSelect:position]];
    
    if ([[self selection] unit] != nil)
    {
        [self.display setDisplayFor:[self selection]];
    }
}


- (void) turn_drive:(CGPoint)position
{
    if ( [self selection] == nil ||
            ([self selection] != nil &&
                currentAction == UNKNOWN &&
                    !isMenuOpen) ) {
                
        CCLOG(@"==================TURN PHASE A: Make a selection");

        [self setSelection:[self.brain doSelect:position]];
        if ( [[self selection] unit] != nil ) {
            // display info here
            [self.display setDisplayFor:[self selection]];
            
            if ( [[self selection] isOwned] ) {
                // Show visual selection
                [[[self selection] unit] action:IDLE at:CGPointZero];
                
                // Open the menu and set flag
                [[[self selection] unit] toggleMenu:YES];
                isMenuOpen = true;
            }
        }
    }
    
    else if ( [self selection] != nil &&
                currentAction == UNKNOWN &&
                isMenuOpen ) {
        
        CCLOG(@"==================TURN PHASE B: Deselection");
        // We remove the selection
        [[[[self selection] unit] sprite] stopAllActions];
        
        // Close the menu and set flag
        [[[self selection] unit] toggleMenu:NO];
        isMenuOpen = false;
        [self setSelection:nil];
        [self turn_drive:position];
        
    } else if ( !isMenuOpen &&
                [self selection] != nil &&
                    currentAction != UNKNOWN &&
                        CGPointEqualToPoint(confirming,CGPointZero) ) {
        
        CCLOG(@"==================TURN PHASE C: Confirm the action");
        CGPoint target = [[self brain] findBrdPos:position];
        CCSprite *temp = [[self tmxLayer] tileAt:ccp(MAPLENGTH-1-target.x, MAPWIDTH-1-target.y)];
        
        if (![self isccColor3B:temp.color theSame:ccWHITE]) {
            // Save color
            ccColor3B save = temp.color;
            
            //Tile is highlighted, legit
            confirming = target;
            
            // We unhighlight and rehighlight the confirming tile
            [self highlightArea:false];
            [temp setColor:save];
            
        } else {
            // The selection was not highlighted
            [self highlightArea:NO];
            
            // We remove the selection
            [[[[self selection] unit] sprite] stopAllActions];
            
            // Close the menu
            [[[self selection] unit] toggleMenu:NO];
            
            // Remove current action
            currentAction = UNKNOWN;
            
            // Undo last button disable
            [[[self selection] unit] undoLastButton];
            [self setSelection:nil];
            
        }
        
    } else if ( !isMenuOpen &&
                    [self selection] != nil &&
                        currentAction != UNKNOWN &&
                            !CGPointEqualToPoint(confirming,CGPointZero) ) {
        CCLOG(@"==================TURN PHASE D: Perform an action");
        
        // Find the target to compare with the confirming
        CGPoint target = [[self brain] findBrdPos:position];
        
        // No matter what we will unhighlight the confirming tile
        CCSprite *temp = [[self tmxLayer] tileAt:ccp(MAPLENGTH-1-confirming.x,
                                                     MAPWIDTH-1-confirming.y)];
        [temp setColor:ccWHITE];
        CGPoint boardPos = [[self selection] boardPos];
        
        // If the target and the confirmed tile is the same + action is legit (redundent)
        NSInteger dmg = 0;
        if ( ( CGPointEqualToPoint(confirming,target) || currentAction == DEFN ) &&
                [[self brain] doAction:currentAction
                                   for:[self selection]
                                    to:position
                                   dmg:&dmg] ) {
            // Add to used tiles
            [usedTiles addObject:[self selection]];
                    
            // Use up some command points
            [self.myCP usedAmount:costOfAction];
                    
            // reorder child
            [self reorderTile:[self selection]];
                    
            // Send data
            [self sendDatafrom:boardPos to:position costs:costOfAction dmg:dmg];
                    
        } else {            
            [[[[self selection] unit] sprite] stopAllActions];
            [[[self selection] unit] undoLastButton];
            [self setSelection:nil];

            // Open menu and set flag
            [[[self selection] unit] toggleMenu:NO];
            isMenuOpen = true;
            
        }
        
        if ( [self.myCP isOutOfPoints] ) {
            CCLOG(@"==================TURN FINISHED==================");
            [self passPressed];
            
        } else {
            CCLOG(@"==================NEXT ACTION====================");
            currentAction = UNKNOWN;
            isMenuOpen = true;
            confirming = CGPointZero;

        }
    }
}

- (void) passPressed
{
    if ( isMyTurn ) {
        NSLog(@">[MYLOG]    Passing the turn!");
        [[self.selection unit] toggleMenu:NO];
        [self.myCP turnEnded];
        [self reset:!isMyTurn];
        for (Tile *tile in usedTiles) {
            NSLog(@">>>>>[MYLOG]    Reset %@",tile);
            [[tile unit] reset];
        }
        [usedTiles removeAllObjects];
        [self sendEndTurn];
    }
}

- (void) sendDatafrom:(CGPoint)boardPos to:(CGPoint)p costs:(int)cost dmg:(int)dmg
{
    NSLog(@"Sending data [%f,%f], action %d, for %d, [%f,%f]",p.x,p.y,currentAction,0,boardPos.x,boardPos.y);

    SFSObject *obj = [SFSObject newInstance];
    [obj putInt:@"xBoard" value:boardPos.x];
    [obj putInt:@"yBoard" value:boardPos.y];
    [obj putInt:@"xPos" value:p.x];
    [obj putInt:@"yPos" value:p.y];
    [obj putInt:@"effect" value:dmg];
    [obj putInt:@"action" value:currentAction];
    [obj putInt:@"cost" value:cost];
    
    // Send the message, targetRoom is nil due to default being last joined room
    [smartFox send:[PublicMessageRequest requestWithMessage:@"gameAction" params:obj targetRoom:nil]];
}

- (void) sendEndTurn
{
    [smartFox send:[PublicMessageRequest requestWithMessage:@"endTurn"]];
}

- (void) onPublicMessage:(SFSEvent *)evt
{
    SFSUser *sender = [evt.params objectForKey:@"sender"];
    NSString *message = [evt.params objectForKey:@"message"];
    SFSObject *data = [evt.params objectForKey:@"data"];
    NSLog(@">[MYLOG]    Received a public message from %@",sender.name);
    if ([sender.name isEqual:smartFox.mySelf.name]) {
        NSLog(@">>>>>>>>>>> It's me LOL");
        
    } else {
        NSLog(@">>>>>>>>>>> %@", message);
        if ( [message isEqual:@"endTurn"]) {
            [self.opCP turnEnded];
            [self reset:YES];
        } else if ( [message isEqual:@"gameAction"] ) {
            [self.opCP usedAmount:[data getInt:@"cost"]];
            [self.brain doOppAction:data];
        }
    }
}

- (BOOL)isccColor3B:(ccColor3B)color1 theSame:(ccColor3B)color2
{
    if ((color1.r == color2.r) && (color1.g == color2.g) && (color1.b == color2.b)){
        return YES;
    } else {
        return NO;
    }
}

- (void) reorderTile:(Tile *)tile
{
    int pos = tile.boardPos.x + tile.boardPos.y;
    [self.gameLayer reorderChild:[[tile unit] spriteSheet] z:SPRITES_TOP - pos];
}

- (void) highlightArea:(bool)highlight
{
    CCLOG(@">[MYLOG]        BattleLayer::highlightArea is centering around %@", [self selection] );
    
    int action = currentAction;
    ccColor3B colour;
    
    // Find the colour to highlight ground
    switch ( action ) {
        case MOVE:
            colour = ccDODGERBLUE;
            break;
        case ATTK:
            colour = ccORANGE;
            break;
        case GORGON_SHOOT:
            colour = ccORANGE;
            break;
        case GORGON_FREEZE:
            colour = ccDARKCYAN;
            break;
        default:
            CCLOG(@"Error! Unknown action occurred: %d", action);
            break;
    }

    if ( highlight ) {
        self.highlights = [[self brain] findActionTiles:[self selection] action:action];
        for (NSValue *v in self.highlights) {
            CGPoint pos = [v CGPointValue];

            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:colour];
            }
        }
    } else {
        for (NSValue *v in self.highlights) {
            CGPoint pos = [v CGPointValue];
            
            if ([self.brain isValidTile:pos]) {
                // the registration point is the top corner
                CCSprite *temp = [self.tmxLayer tileAt:ccp(MAPLENGTH-1-pos.x,MAPWIDTH-1-pos.y)];
                [temp setColor:ccWHITE];
            }
        }
    }
}

// Unit Delegate
- (BOOL) pressedButton:(int)action turn:(int)cost
{
    // Check if cost is too high
    costOfAction = cost;
    if ( cost > [self.myCP cpAmount] ) {
        NSLog(@">[MYLOG]    action failed due to insignificant CP");
        return NO;
    } else {
        isMenuOpen = false;
        if ( action == MOVE ) {
            currentAction = MOVE;
            [self highlightArea:true];
            
        } else if ( action == ATTK ) {
            currentAction = ATTK;
            [self highlightArea:true];
            
        } else if ( action == DEFN ) {
            currentAction = DEFN;
            confirming = ccp(1,1);
            [self turn_drive:confirming];
            
        } else if ( action == GORGON_SHOOT ) {
            currentAction = GORGON_SHOOT;
            [self highlightArea:YES];
            
        } else if ( action == GORGON_FREEZE ) {
            currentAction = GORGON_FREEZE;
            [self highlightArea:YES];
            
        }
        return YES;
    }
}

- (void)kill:(CGPoint)position;
{
    [self.brain killtile:position];
}

// Brain Delegate
- (void)loadTile:(Tile *)tile
{
    [[[tile unit] sprite] setPosition:tile.absPos];
    [[tile unit] setDelegate:self];
    [self.gameLayer addChild:[[tile unit] spriteSheet] z:SPRITES_TOP];
    [self reorderTile:tile];
    if (tile.isOwned) [self.gameLayer addChild:[[tile unit] menu] z:MENUS];
    CCLOG(@"    loaded unit at %@",tile);
}

- (void)failToLoad
{
    [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
}

- (void)unitDidMoveTo:(Tile *)tile
{
    [self setSelection:tile];
}

-(void)displayCombatMessage:(NSString*)message atPosition:(CGPoint)point with:(ccColor3B)color;
{
    NSLog(@">[MYLOG]        Displaying %@, at [%f,%f]",message,point.x,point.y);
    //used in determining how long the slide/fade lasts
    float slideDuration = 2.5f;
    
    //used in determining how far up/down along Y the label changes
    //positive = UP, negative = DOWN
    float yChange = 100;
    
    //used in determining how far left/right along the X the label changes
    //positive = RIGHT, negative = LEFT
    float xChange = 0;
    
    //set up the label
    CCLabelBMFont *lblMessage = [CCLabelBMFont labelWithString:message fntFile:@"emulator.fnt"];
    
    //Change the color
    lblMessage.color = color;
    
    //position the label where you want it...
    lblMessage.position = point;
    
    //add the LABEL to the screen
    [self.gameLayer addChild:lblMessage z:DISPLAYS];
    
    //the method that will slide label up
    //the "position" is how much it moves by... going straight up means 0 on the X, and a positive value on the Y
    id slideUp = [CCMoveBy actionWithDuration:slideDuration position:ccp(xChange,yChange)];
    
    //the method that will fade label out
    //i just pass the same duration so it can
    id fadeOut = [CCFadeOut actionWithDuration:slideDuration];
    
    //run the actions on the LABEL
    [lblMessage runAction:fadeOut];
    [lblMessage runAction:slideUp];
    
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
    [self.gameLayer addChild:lblMessage z:DISPLAYS];

    id waitHere = [CCDelayTime actionWithDuration:delayDuration];
    id slideTwo = [CCMoveBy actionWithDuration:slideDuration position:ccp(xChange, yChange)];
    
    //run the actions on the LABEL
    [lblMessage runAction:waitHere];
    [lblMessage runAction:slideTwo];
    
    //the waiting for the slide/fade to complete
    id waitForSlide = [CCDelayTime actionWithDuration:delayDuration];
    id removeLabel = [CCCallBlock actionWithBlock:^{
        [self.gameLayer removeChild:lblMessage cleanup:YES];
        isMyTurn = myTurn;
    }];
    id sequence = [CCSequence actions:waitForSlide, removeLabel, nil];
    
    //actually run the sequence
    [self runAction:sequence];
}

- (void) addSprite:(CCSprite *)sprite z:(int)z
{
    [self.gameLayer addChild:sprite z:z];
}
@end