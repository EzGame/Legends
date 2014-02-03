//
//  SetupMenuLayer.h
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//

#import "cocos2d.h"
#import "Constants.h"
#import "NodeReporter.h"
#import "CCScrollLayer.h"

@interface SetupMenuLayer : CCLayer {
    NSMutableArray *items;
    
    CCLayerColor *background; // TODO: Change to CCSprite
    CCScrollLayer *setups;
}
@property (nonatomic, assign) CGRect viewArea;

+ (SetupMenuLayer *) createWithView:(CGRect)area;
@end



@interface SetupNode : CCNode <NodeReporter>
{
    CCSprite *button;
    CCLabelBMFont *label;
}
@property (nonatomic, strong) NSMutableString *string;

+ (SetupNode *) setupWithString:(NSString *)setup; // TODO: Chance to JSON
@end
