//
//  ChampionViewController.m
//  LoL Scouter
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 Chris Bernt. All rights reserved.
//

#import "ChampionViewController.h"

@interface ChampionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@end

@implementation ChampionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myLabel.text = self.summonerId;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
