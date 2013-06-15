//
//  LoginViewController.h
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import <UIKit/UIKit.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "AppDelegate.h"
#import "UserSingleton.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, ISFSEvents>
{
    BOOL isPassOK;

    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}

@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *confirm;

@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) IBOutlet UIButton *accnt;
@property (strong, nonatomic) IBOutlet UIButton *create;

@end
