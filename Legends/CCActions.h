//
//  CCActions.h
//  myFirstApp
//
//  Created by David Zhang on 2013-01-25.
//
//

// Auto includes
#import "cocos2d.h"
#import "Defines.h"

// Others
#import "CCAction.h"


@interface CCActions : NSObject

@property (nonatomic, strong) CCAction          *action_NE;
@property (nonatomic, strong) CCAction          *action_SE;
@property (nonatomic, strong) CCAction          *action_SW;
@property (nonatomic, strong) CCAction          *action_NW;

- (id)initWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forAction:(int)action;
+ (id)actionsWithSpriteSheet:(CCSpriteBatchNode *)spriteSheet forAction:(int)action;
@end
