//
//  SetupSuppLayers.h
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//

#import "cocos2d.h"
#import "Constants.h"
#import "GeneralUtils.h"
#import "UserSingleton.h"

#import "NodeReporter.h"
#import "CCScrollLayer.h"


#pragma mark - Setup Menu Layer
@protocol SetupMenuLayerDelegate <NSObject>
- (void) setupMenuLayerWantsToLoadSetup:(NSMutableDictionary *)setup;
@end

@interface SetupMenuLayer : CCLayer<CCScrollLayerDelegate> {
    CCLayerColor *background; // TODO: Change to CCSprite
}

@property (nonatomic, strong)              CCScrollLayer *setups;
@property (nonatomic, assign)                     CGRect viewArea;
@property (nonatomic, assign) id<SetupMenuLayerDelegate> delegate;

+ (SetupMenuLayer *) createWithView:(CGRect)area
                          setuplist:(NSMutableArray *)setuplist
                           delegate:(id<SetupMenuLayerDelegate>)delegate;
@end

#pragma mark - Setup Node
@interface SetupNode : CCNode <NodeReporter>

@property (nonatomic, strong)            CCSprite *button;
@property (nonatomic, strong)       CCLabelBMFont *label;
@property (nonatomic, strong) NSMutableDictionary *dict;

+ (SetupNode *) createWithDict:(NSMutableDictionary *)dict;
@end









#pragma mark - Setup Unit Menu Layer
@protocol SetupUnitMenuLayerDelegate <NSObject>
- (void) setupUnitMenuLayerWantsToLoadUnit:(NSMutableDictionary *)unit;
@end

@interface SetupUnitMenuLayer : CCLayer <CCScrollLayerDelegate>

@property (nonatomic, strong)                  CCScrollLayer *units;
@property (nonatomic, assign)                         CGRect viewArea;
@property (nonatomic, assign) id<SetupUnitMenuLayerDelegate> delegate;

+ (SetupUnitMenuLayer *) createWithView:(CGRect)area
                                   list:(NSMutableArray *)unitlist
                               delegate:(id<SetupUnitMenuLayerDelegate>)delegate;
@end

#pragma mark - Setup Unit Node
@interface SetupUnitNode : CCNode <NodeReporter>

@property (nonatomic, strong)            CCSprite *button;
@property (nonatomic, strong)       CCLabelBMFont *label;
@property (nonatomic, strong) NSMutableDictionary *dict;

+ (SetupUnitNode *) createWithDict:(NSMutableDictionary *)dict;
@end