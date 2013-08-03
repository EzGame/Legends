//
//  LionMage.m
//  Legends
//
//  Created by David Zhang on 2013-07-16.
//
//
#define LIONMAGESCALE 1
#define LIONMAGESETUPSCALE LIONMAGESCALE * SETUPMAPSCALE
#import "LionMage.h"
@interface LionMage ()
@property (nonatomic, strong) CCAction *death;
@end
@implementation LionMage
const NSString *LIONMAGE_MOVE_DESP = @"-";
const NSString *LIONMAGE_ONE_DESP = @"Heal all";

@synthesize idle = _idle, move = _move, heal = _heal;
@synthesize moveButton = _moveButton, healButton = _healButton, healEffect = _healEffect;
@synthesize direction = _direction;

#pragma mark - Setters and getters
- (void) setDirection:(int)direction
{
    if ( direction == NE )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_NE_0.png"]];
    else if ( direction == NW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_NW_0.png"]];
    else if ( direction == SW )
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_SW_0.png"]];
    else
        [self.sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lionmage_idle_SE_0.png"]];
    _direction = direction;
}

#pragma mark - Alloc n Init

+ (id) lionmageWithObj:(UnitObj *)obj;
{
    return [[LionMage alloc] initLionmageFor:YES withObj:obj];
}

+ (id) lionmageForEnemyWithObj:(UnitObj *)obj;
{
    return [[LionMage alloc] initLionmageFor:NO withObj:obj];
}

+ (id) lionmageForSetupWithObj:(UnitObj *)obj;
{
    return [[LionMage alloc] initLionmageForSetupWithObj:obj];
}

- (id) initLionmageFor:(BOOL)side withObj:(UnitObj *)obj;
{
    self = [super initForSide:side withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lionmage_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lionmage_default.png"];
        
        _idle = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"lionmage_idle" andFrames:2 delay:0.5];
        _idle.tag = IDLETAG;
        
        _move = [CCActions actionsInfiniteWithSpriteSheet:self.spriteSheet forName:@"lionmage_walk" andFrames:8 delay:0.1];
        
        _heal = [CCActions actionsWithSpriteSheet:self.spriteSheet forName:@"lionmage_cast" andFrames:6 delay:0.1 reverse:NO];
        
        self.sprite = [CCSprite node];
        CCSprite *base = [CCSprite spriteWithSpriteFrameName:@"unit_base.png"];
        CCSprite *unit;
        if ( side ) {
            unit = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_NE_0.png"];
            base.color = ccWHITE;
            self.direction = NE;
        } else {
            unit = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_SW_0.png"];
            base.color = ccRED;
            self.direction = SW;
        }
        
        [self initMenu];
        [self initEffects];
        
        self.sprite.scale = LIONMAGESCALE;
        
        [self.sprite addChild:base z:-1];
        [self.sprite addChild:unit z:0];
        [self.spriteSheet addChild:self.sprite z:0];
    }
    return self;
}

- (id) initLionmageForSetupWithObj:(UnitObj *)obj;
{
    self = [super initForSide:YES withObj:obj];
    if ( self )
    {
        // Cache the sprite frames and texture
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lionmage_default.plist"];
        
        // Create a sprite batch node
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"lionmage_default.png"];
        
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"lionmage_idle_SW_0.png"];
        
        self.sprite.scale = LIONMAGESETUPSCALE;
        
        [self.spriteSheet addChild:self.sprite];
    }
    return self;
}

- (void) initMenu
{
    _moveButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_move.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_2.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(movePressed)];
    _moveButton.position = ccp(-40,60);
    _moveButton.costOfButton = 2;
    
    _healButton = [MenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_cross-coloured.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"button_overlay_3.png"]
                                        disabledSprite:nil
                                                target:self
                                              selector:@selector(healPressed)];
    _healButton.position = ccp(40,60);
    _healButton.costOfButton = 3;
    
    self.menu = [CCMenu menuWithItems:_moveButton, _healButton, nil];
    self.menu.visible = NO;
}

- (void) initEffects
{
    // DEATH
    NSMutableArray *frames0 = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames0 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"deathorb_%d.png",i]]];
    }
    
    CCAnimation *animation0 = [[CCAnimation alloc] initWithSpriteFrames:frames0 delay:0.08];
    animation0.restoreOriginalFrame = NO;
    _death = [[CCAnimate alloc] initWithAnimation:animation0];
    
    // HEAL
    NSMutableArray *frames1 = [NSMutableArray array];
    
    for (int i = 0; i < 5; i++) {
        [frames1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                            spriteFrameByName:[NSString stringWithFormat:@"heal_%d.png",i]]];
    }
    
    CCAnimation *animation1 = [[CCAnimation alloc] initWithSpriteFrames:frames1 delay:0.15];
    animation1.restoreOriginalFrame = NO;
    _healEffect = [[CCRepeatForever alloc] initWithAction:[[CCAnimate alloc] initWithAnimation:animation1]];
}

#pragma mark - Actions + combat

- (void) action:(int)action at:(CGPoint)position
{
    [self.sprite stopAllActions];
    CGPoint difference = ccpSub(position, self.sprite.position);
    if ( action != IDLE && action != DEAD && action != HEAL_ALL) {
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
        [self popStepAndAnimate];
        
    } else if ( action == HEAL_ALL ) {
        [self.healButton setIsUsed:YES];
        int damage = [self.attribute getInt]*2;
        health = MIN(health+damage, self.attribute->max_health);

        id start = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[self.heal getActionFor:self.direction]];
        }];
        id delay = [CCDelayTime actionWithDuration:0.6];
        id healText = [CCCallBlock actionWithBlock:^{
            [self.sprite setColor:ccGREEN];
            [self.delegate displayCombatMessage:[NSString stringWithFormat:@"+%d",damage] atPosition:self.sprite.position withColor:ccGREEN];
        }];
        id healDelay = [CCDelayTime actionWithDuration:0.2];
        id healFinish = [CCTintTo actionWithDuration:1 red:255 green:255 blue:255];
        id finish = [CCCallBlock actionWithBlock:^{
            [self.sprite stopAllActions];
            [self action:IDLE at:CGPointZero];
            if ( self.isOwned ) [self toggleMenu:YES];
        }];
        [self.sprite runAction:[CCSequence actions:start, delay, healText,
                                healDelay, healFinish, finish, nil]];
        
        NSAssert(self.targets != nil, @"TARGETS NIL WTF");
        for ( NSValue *v in self.targets )
        {
            CCSprite *heal = [CCSprite spriteWithSpriteFrameName:@"heal_0.png"];
            heal.position = ccpAdd(ccp(0,10),[v CGPointValue]);
            heal.visible = NO;
            [self.delegate addSprite:heal z:EFFECTS];
            
            id effectDelay = [CCDelayTime actionWithDuration:0.6];
            id effectStart = [CCCallBlock actionWithBlock:^{
                heal.visible = YES;
                [heal runAction:[self.healEffect copy]];
            }];
            id effectRun = [CCDelayTime actionWithDuration:0.75];
            id effectFade = [CCCallBlock actionWithBlock:^{
                [heal runAction:[CCFadeOut actionWithDuration:0.75]];
            }];
            id effectFinish = [CCCallBlock actionWithBlock:^{
                [self.delegate removeSprite:heal];
            }];
            
            [heal runAction:[CCSequence actions:
                             effectDelay, effectStart, effectRun,
                             effectFade, effectRun, effectFinish, nil]];
        }
            
        
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
        NSLog(@">[MYWARN]   LIONMAGE: I cant handle this LOL");
    }
}

- (void) popStepAndAnimate {
    // Check if there remains path steps to go through
    if ([[self shortestPath] count] == 0) {
        [[self sprite] stopAllActions];
        [self.delegate actionDidFinish:self];
        [self action:IDLE at:CGPointZero];
        if (self.isOwned) [self toggleMenu:YES];
        [self setShortestPath: nil];
        return;
    }
    
    // Get the next step to move to
    ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    NSLog(@"%@! %@",self,s);
    CGPoint difference = ccpSub([s position], [[self sprite] position]);
    float duration = ccpLength(ccpSub([s position],self.sprite.position))/60;
    
    // Find the facing direction
    if (difference.x >= 0 && difference.y >= 0) {

            [self.sprite stopAllActions];
            [self.sprite runAction:self.move.action_NE];
            self.direction = NE;
    } else if (difference.x >= 0 && difference.y < 0) {

            [self.sprite stopAllActions];
            [self.sprite runAction:self.move.action_SE];
            self.direction = SE;
    } else if (difference.x < 0 && difference.y < 0) {

            [self.sprite stopAllActions];
            [self.sprite runAction:self.move.action_SW];
            self.direction = SW;
    } else {

            [self.sprite stopAllActions];
            [self.sprite runAction:self.move.action_NW];
            self.direction = NW;
    }
    
    // Prepare the action and the callback
    id moveAction = [CCMoveTo actionWithDuration:duration position:[s position]];
    id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    [self.shortestPath removeObjectAtIndex:0];
    
    // Play actions
    [[self sprite] runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}

- (void) take:(int)damage after:(float)delay
{
    [self.sprite stopAllActions];
    health -=damage;
    NSString *directionFrame;
    if ( self.direction == NE )
        directionFrame = @"lionmage_knockback_NE.png";
    else if ( self.direction == NW )
        directionFrame = @"lionmage_knockback_NW.png";
    else if ( self.direction == SE )
        directionFrame = @"lionmage_knockback_SE.png";
    else if ( self.direction == SW )
        directionFrame = @"lionmage_knockback_SW.png";
    
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
    return [super canIDo:action];
}

- (void) movePressed
{
    if ( ![self.moveButton isUsed] && [self canIDo:MOVE] ) {
        if ( [self.delegate pressedButton:MOVE] ) {
            [self toggleMenu:NO];
        }
    }
}

- (void) healPressed
{
    if ( ![self.healButton isUsed] && [self canIDo:HEAL_ALL] ) {
        if ( [self.delegate pressedButton:HEAL_ALL] ) {
            [self toggleMenu:NO];
        }
    }
}

#pragma mark - Misc

- (NSString *) description
{
    return [NSString stringWithFormat:@"Lionmage Lv.%d",self.level];
}

- (void) reset
{
    [super reset];
    self.coolDown--;
    if ( self.moveButton.isUsed ) self.coolDown += self.moveButton.costOfButton;
    if ( self.healButton.isUsed ) self.coolDown += self.healButton.costOfButton;
    self.moveButton.isUsed = NO;
    self.healButton.isUsed = NO;
}

- (BOOL) hasActionLeft
{
    return !self.moveButton.isUsed || !self.healButton.isUsed;
}

@end
