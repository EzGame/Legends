//
//  MainMenuViewController.h
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import <UIKit/UIKit.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "AppDelegate.h"
#import "UserSingleton.h"

@interface MainMenuViewController : UIViewController <ISFSEvents>
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (strong, nonatomic) IBOutlet UIButton *battle;
@property (strong, nonatomic) IBOutlet UIButton *setup;
@property (strong, nonatomic) IBOutlet UIButton *bag;

@property (strong, nonatomic) IBOutlet UIButton *fastMatch;
@property (strong, nonatomic) IBOutlet UIButton *avgMatch;
@property (strong, nonatomic) IBOutlet UIButton *infMatch;
@property (strong, nonatomic) IBOutlet UIButton *friendsMatch;
@end
