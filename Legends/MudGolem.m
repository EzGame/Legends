//
//  MudGolem.m
//  Legends
//
//  Created by David Zhang on 2013-06-26.
//
//
#define MUDGOLEMSCALE 0.85
#define MUDGOLEMSETUPSCALE MUDGOLEMSCALE * SETUPMAPSCALE
#import "MudGolem.h"

@interface MudGolem()
@property (nonatomic, strong) CCAction *death;
@end

@implementation MudGolem
const NSString *MUDGOLEM_TWO_DESP = @"Range - Physical";
const NSString *MUDGOLEM_ONE_DESP = @"Melee - Physical";
const NSString *MUDGOLEM_MOVE_DESP = @"Teleporting";

@synthesize idle = _idle, move = _move, moveEnd = _moveEnd, attk = _attk, earthquake = _earthquake;
@synthesize moveButton = _moveButton, attkButton = _attkButton, earthquakeButton = _earthquakeButton;
// Stuff from Unit
@synthesize direction = _direction;

#pragma mark - Setters and getters
- (void) setDirection:(int)direction
{
    if ( direction == NE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_NE_0.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_NW_0.png"]];
    else if ( direction == SE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_SE_0.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mudgolem_idle_SW_0.png"]];
    
    _direction = direction;
}

#pragma mark - Alloc n Init

+ (id) mudGolemWithObj:(UnitObj *)obj
{
    return [[MudGolem alloc] initMudGolemFor:YES withObj:obj];
}

+ (id) mudGolemForEnemyWithObj:(UnitObj *)obj
{
    return [[MudGolem alloc] initMudGolemFor:NO withObj:obj];
}

+ (id) mudGolemForSetupWithObj:(UnitObj *)obj
{
    return [[MudGolem alloc] initMudGolemForSetupWithObj:obj];
}

- (id) initMudGolemFor:(BOOL)side withObj:(UnitObj *)obj
{
    self = [super initForSide:side withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mudgolem_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mudgolem_default.png"];
        
        _idle = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"mudgolem_idle" andFrames:2 delay:0.5];
        _idle.tag = IDLETAG;

        _move = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_sink" andFrames:6 delay:0.1 reverse:NO];
        _moveEnd = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_sink" andFrames:6 delay:0.1 reverse:YES];
        _attk = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_punch" andFrames:4 delay:0.12 reverse:NO];
        _earthquake = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"mudgolem_smash" andFrames:7 delay:0.1 reverse:NO];
        
        CCSprite *temp = [CCSprite spriteWithSpriteFrameName:@"unit_base.png"];
        if ( side ) {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"mudgolem_idle_NE_0.png"];
            self.direction = NE;
            temp.color = ccWHITE;
        } else {
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"mudgolem_idle_SW_0.png"];
            self.direction = SW;
            temp.color = ccRED;
        }
        
        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = MUDGOLEMSCALE;
        
        [self.sprite addChild:temp z:-1];
        [self.spriteSheet addChild:self.sprite z:0];
    }
    return self;
}

- (id) initMudGolemForSetupWithObj:(UnitObj *)obj
{
    self = [super initForSide:YES withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mudgolem.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"mudgolem.png"];
        
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"mudgolem_idle_SW_0.png"];
                
        self.sprite.scale = MUDGOLEMSETUPSCALE;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_phase.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-50,60);
    _moveButton.costOfButton = 1;
    
    _attkButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_melee.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_1.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(attkPressed)];
    _attkButton.position = ccp(0,85);
    _attkButton.costOfButton = 1;
    
    _earthquakeButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_earthquake.png"]
                                              selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                              disabledSprite:nil
                                                      target:self
                                                    selector:@selector(earthquakePressed)];
    _earthquakeButton.position = ccp(50,60);
    _earthquakeButton.costOfButton = 2;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _attkButton, _earthquakeButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects
{
    // DEATH
    NSMutableArray *frames = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"deathorb_%d.png",i]]];
    }
    
    CCAnimation *animation = [[CCAnimation alloc] initWithSpriteFrames:frames delay:0.1];
    animation.restoreOriginalFrame = NO;
    _death = [[CCAnimate alloc] initWithAnimation:animation];
}

#pragma mark - Actions + combat

- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.sprite.position);
    if ( action != IDLE && action != DEAD && action != MUDGOLEM_EARTHQUAKE) {
        // Find the facing direction
        if (difference.x >= 0 && difference.y >= 0)
            self.direction = NE;
        else if (difference.x >= 0 && difference.y < 0)
            self.direction = SE;
        else if (difference.x < 0 && difference.y < 0)
            self.direction = SW;
        else
            self.direction = NW;
    }
    
    if ( action == IDLE ) {
        [self.delegate actionDidFinish:self];
        [self.sprite runAction:[self.idle getActionFor:self.direction]];
        
    } else if ( action == MOVE ) {
        [self.moveButton setIsUsed:YES];
        
        /////////
        id delay = [CCDelayTime actionWithDuration:0.4];
        /////////
        id move1 = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:[self.move getActionFor:self.direction]]; }];
        id fadeout = [CCFadeOut actionWithDuration:0.2];
        id fade1 = [CCSequence actions:delay, fadeout,  nil];
        id sink = [CCSpawn actions:move1, fade1, nil];
        /////////
        id move2 = [CCCallBlock actionWithBlock:^{
            self.sprite.position = position;
            [self.sprite runAction:[self.moveEnd getActionFor:self.direction]];
        }];
        id fadein = [CCFadeIn actionWithDuration:0.2];
        id fade2 = [CCSequence actions:fadein, delay, nil];
        id rise = [CCSpawn actions:move2, fade2, nil];
        /////////
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        
        [self.sprite runAction:[CCSequence actions:sink, rise, finish, nil]];
            
    } else if ( action == ATTK ) {
        [self.attkButton setIsUsed:YES];
        [self.earthquakeButton setIsUsed:YES];
        
        id part1 = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:[self.attk getActionFor:self.direction]];}];
        id part2 = [CCDelayTime actionWithDuration:0.4];
        id part3 = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];

        [self.sprite runAction:[CCSequence actions:part1, part2, part3, nil]];

    } else if ( action == MUDGOLEM_EARTHQUAKE ) {
        [self.earthquakeButton setIsUsed:YES];
        [self.attkButton setIsUsed:YES];
        CCSprite *crack = [CCSprite spriteWithSpriteFrameName:@"earthquake_crack.png"];
        [self.delegate addSprite:crack z:GROUND_EFFECTS];
        crack.position = self.sprite.position;
        crack.visible = NO;
        
        id spriteStart = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.earthquake getActionFor:self.direction]];}];
        id spriteDelay = [CCDelayTime actionWithDuration:0.6];
        id spriteEnd = [CCCallBlock actionWithBlock:^{
            crack.visible = YES;
            //[self.delegate shakeScreen];
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        id crackDelay = [CCDelayTime actionWithDuration:8];
        id crackFade = [CCCallBlock actionWithBlock:^{
            [crack runAction:[CCFadeOut actionWithDuration:2]];
        }];
        id crackFadeDelay = [CCDelayTime actionWithDuration:2];
        id crackEnd = [CCCallBlock actionWithBlock:^{
            [self.delegate removeSprite:crack];
        }];
        
        [self.sprite runAction:[CCSequence actions:spriteStart, spriteDelay, spriteEnd, nil]];
        [crack runAction:[CCSequence actions:spriteDelay, crackDelay, crackFade, crackFadeDelay, crackEnd, nil]];
        
    } else if ( action == DEAD ) {
        CCSprite *orb = [CCSprite spriteWithSpriteFrameName:@"deathorb_0.png"];
        [self.delegate addSprite:orb z:EFFECTS];
        orb.position = self.sprite.position;
        orb.visible = NO;
        
        id fade = [CCFadeOut actionWithDuration:0.4];
        id form = [CCCallBlock actionWithBlock:^{
            orb.visible = YES;
            [orb runAction:self.death];
        }];
        id die = [CCSpawn actions:fade, form, nil];
        ///////
        id spritefade = [CCCallBlock actionWithBlock:^{ [self.sprite runAction:die]; }];
        id delay = [CCDelayTime actionWithDuration:0.5];
        id orbfade = [CCCallBlock actionWithBlock:^{ [orb runAction:[CCFadeOut actionWithDuration:0.2]];}];
        id finish = [CCCallBlock actionWithBlock:^{
            self.sprite.visible = false;
            [self.delegate removeSprite:orb];
            [self.delegate killMe:self at:self.sprite.position];
        }];
        
        [self.sprite runAction:[CCSequence actions:spritefade, delay, orbfade, finish, nil]];
        
    } else {
        NSLog(@">[MYWARN]   MUDGOLEM: I can't handle this LOL");
    }
}

- (void) take:(int)damage after:(float)delay
{
    [self.sprite stopAllActions];
    health -= damage;
    NSString *directionFrame;
    if ( self.direction == NE )
        directionFrame = @"mudgolem_knockback_NE.png";
    else if ( self.direction == NW )
        directionFrame = @"mudgolem_knockback_NW.png";
    else if ( self.direction == SE )
        directionFrame = @"mudgolem_knockback_SE.png";
    else if ( self.direction == SW )
        directionFrame = @"mudgolem_knockback_SW.png";
    
    [self.sprite runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:delay],
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccRED];
         [self.delegate displayCombatMessage:[NSString stringWithFormat:@"%d!",damage]
                                  atPosition:self.sprite.position withColor:ccRED];
         [self.sprite setDisplayFrame:
          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:directionFrame]];
     }],
      [CCDelayTime actionWithDuration:0.5],
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccWHITE];
         self.direction = self.direction;
         if ( health < 1 ) [self action:DEAD at:CGPointZero];
     }], nil]];
}

- (void) heal:(int)damage after:(float)delay
{
    [self.sprite stopAllActions];
    health = MIN(health+damage, self.attribute->max_health);
    
    [self.sprite runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:delay],
      [CCCallBlock actionWithBlock:^{
         [self.sprite setColor:ccGREEN];
         [self.delegate displayCombatMessage:[NSString stringWithFormat:@"+%d",damage]
                                  atPosition:self.sprite.position withColor:ccGREEN];
     }],
      [CCDelayTime actionWithDuration:0.2],
      [CCTintTo actionWithDuration:1 red:255 green:255 blue:255], nil]];
}


- (int) calculate:(int)damage type:(int)dmgType
{
    return damage;
}

#pragma mark - Menu controls
- (BOOL) canIDo:(int)action
{
    if ( action == MUDGOLEM_EARTHQUAKE ) {
        return YES;
    } else {
        return [super canIDo:action];
    }
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate pressedButton:TELEPORT_MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) attkPressed
{
    if ( ![self.attkButton isUsed] && [self canIDo:ATTK] ) {
        if ( [self.delegate pressedButton:ATTK] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) earthquakePressed
{
    if ( ![self.earthquakeButton isUsed] && [self canIDo:ATTK] ) {
        if ( [self.delegate pressedButton:MUDGOLEM_EARTHQUAKE] ) {
            [self toggleMenu:NO];
        }
    }
}

#pragma mark - Misc

- (NSString *) description
{
    return [NSString stringWithFormat:@"Mud Golem Lv.%d", self.level];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed ) self.coolDown += self.moveButton.costOfButton;
    if ( self.attkButton.isUsed ) self.coolDown += self.attkButton.costOfButton;
    if ( self.earthquakeButton.isUsed ) self.coolDown += self.earthquakeButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.attkButton.isUsed = NO;
    self.earthquakeButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.attkButton.isUsed || !self.earthquakeButton.isUsed;
}


- (CGPoint *) getEarthquakeArea { return (CGPoint *)mudgolemEarthquakeArea; }
- (CGPoint *) getEarthquakeEffect { return (CGPoint *)mudgolemEarthquakeEffect; }
- (CGPoint *) getAttkArea { return (CGPoint *)mudgolemAttkArea; }
- (CGPoint *) getAttkEffect { return (CGPoint *)mudgolemAttkEffect; }
@end
