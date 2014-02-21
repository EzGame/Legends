//
//  MainMenuViewController.m
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import "MainMenuViewController.h"
#import "MatchFindingViewController.h"
#import "InventoryViewController.h"
#import "SetupLayer.h"

@interface MainMenuViewController ()
@property (strong, nonatomic) IBOutlet UIView *mainMenuView;
@end

@implementation MainMenuViewController

@synthesize battle = _battle, setup = _setup, bag = _bag;

- (IBAction)infMatchTouched:(id)sender {
    // Join the Match Making Queue
    [smartFox send:[JoinRoomRequest requestWithId:@"MMQueue" pass:@"" roomIdToLeave:nil asSpect:NO]];
}

- (IBAction)battleTouched:(id)sender
{
    NSLog(@">[MYLOG]    Battle!");
    if ( [[UserSingleton get] isFirstLaunch] )
    {
        [appDelegate showAlert:
         [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"!", @"title",
                                      @"Please run setup first", @"msg"
                                      @"Ok", @"cancel", nil]];
    }
    else
    {
        self.setup.hidden = YES;
        self.bag.hidden = YES;
        
        self.fastMatch.hidden = NO;
        self.avgMatch.hidden = NO;
        self.infMatch.hidden = NO;
        self.friendsMatch = NO;
    }
}

- (IBAction)setupTouched:(id)sender
{
    NSLog(@">[MYLOG]    Setup!");
    [appDelegate switchToScene:[SetupLayer scene]];
}

- (IBAction)bagTouched:(id)sender {
    NSLog(@">[MYLOG]    Logout!");
//    [appDelegate switchToView:@"InventoryViewController" uiViewController:[InventoryViewController alloc]];
}

#pragma mark - SFS Event handlers
- (void) onRoomJoin:(SFSEvent *)evt
{
    NSLog(@">[MYLOG]    Sending our user information");
    
    SFSUserVariable *elo =
    [SFSUserVariable variableWithName:@"ELO"
                                value:[NSNumber numberWithInt:[[UserSingleton get] ELO]]];
    SFSUserVariable *value = 
    [SFSUserVariable variableWithName:@"UnitValue"
                                value:[NSNumber numberWithInt:[[UserSingleton get] unitValue]]];
    
    NSArray *userObjs = [NSArray arrayWithObjects: elo, value, nil];
    [smartFox send:[SetUserVariablesRequest requestWithUserVariables:userObjs]];
}

- (void) onRoomJoinError:(SFSEvent *)evt
{
    NSLog(@"shits fucked");
}

- (void) onUserVariablesUpdate:(SFSEvent *)evt
{
    // onUserVariablesUpdate doesn't get called
    NSLog(@">[MYLOG]    ELO/UnitValue uploaded, now moving to Match Making View");
    [appDelegate switchToView:@"MatchFindingViewController" uiViewController:[MatchFindingViewController alloc]];
}


#pragma mark - Other shit
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    smartFox = appDelegate.smartFox;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload
{
    [self setBattle:nil];
    [self setSetup:nil];
    [self setBag:nil];
    [self setMainMenuView:nil];
    [self setFastMatch:nil];
    [self setAvgMatch:nil];
    [self setInfMatch:nil];
    [self setFriendsMatch:nil];
    [super viewDidUnload];
}
@end
