//
//  MatchFindingViewController.h
//  Legend
//
//  Created by David Zhang on 2013-05-01.
//
//

#import <UIKit/UIKit.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "AppDelegate.h"
#import "UserSingleton.h"
#import "BattleLayer.h"

@interface MatchFindingViewController : UIViewController <ISFSEvents>
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
    BOOL matchFound;
    int attemptCount;
    
    BOOL sent;
    BOOL received;
}

@property (strong, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@end
