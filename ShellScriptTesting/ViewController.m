//
//  ViewController.m
//  LoL Scouter
//
//  Created by Chris on 2/23/15.
//  Copyright (c) 2015 Chris Bernt. All rights reserved.
//

#import "ViewController.h"
@import Foundation;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ViewController{
    NSMutableArray* enemies;
    NSMutableDictionary *champIds;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self createChampIdDictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)runScript:(id)sender {
    
    [self showData];
    
}
-(void) cleanUp{
    [self.textField resignFirstResponder];
}

- (void) showData{
    
    NSString* summonerName = [[self textField] text];
    NSString* toSearch = formatString(summonerName);
    
    
    NSString* url = [NSString stringWithFormat: @"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=9b34e42a-5d05-4996-b07a-6a77c9a2d756", toSearch];
    NSDictionary* data = [self getDataFrom:url];
    
    NSString* playerID;
    if(data != nil){
        playerID = [data[toSearch][@"id"] description];
    }
    else{
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid summoner name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self cleanUp];
        [message show];
        return;
    }
    
    
    url = [NSString stringWithFormat: @"https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/%@?api_key=9b34e42a-5d05-4996-b07a-6a77c9a2d756", playerID];
    data = [self getDataFrom:url];
    
    
    if(data == nil){
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:nil message:@"Summoner not in game." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self cleanUp];
        [message show];
        return;
    }
    
    
    
    
    
    
    NSString* teamId = findOwnTeam(playerID, data);
    //NSLog(@"%@", teamId);
    teamId = [NSString stringWithFormat:@"%@", teamId];
    
    enemies = [[NSMutableArray alloc] init];
    
    
    NSArray* participants = data[@"participants"];
    for(int i = 0; i < [participants count]; i++){
        
        NSString* curTeam = participants[i][@"teamId"];
        curTeam = [NSString stringWithFormat:@"%@", curTeam];
        
        
        if(![teamId isEqualToString: curTeam]){
            
            NSString* curID = [NSString stringWithFormat:@"%@", participants[i][@"summonerId"]];
            //NSString* curName = participants[i][@"summonerName"];
            
            //NSLog(@"%@", curName);
            [enemies addObject: [self getSummonerRankedData:curID withChampId:[participants[i][@"championId"] description]   ]];
            
            
        }
        
    }
    
    //NSLog(@"%@", enemies);
    
    [self.myTableView reloadData];
    [self cleanUp];
    


}

NSString* findOwnTeam(NSString* playerID, NSDictionary* data){
    
    NSArray* participants = data[@"participants"];
    
    for(int i = 0; i < [participants count]; i++){
        
        NSString* curID = [NSString stringWithFormat:@"%@", participants[i][@"summonerId"]];
        
        if([curID isEqualToString:playerID]){
            return participants[i][@"teamId"];
        }
    }
    return nil;
}

NSString* formatString(NSString* original){
    return [[[original componentsSeparatedByString:@" "] componentsJoinedByString:@""] lowercaseString];
}

-(NSString*) getSummonerRankedData: (NSString*) playerID withChampId:(NSString*) champId{
    
    //NSLog(@"%@", champId);
    
    NSString* url = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/na/v2.5/league/by-summoner/%@/entry?api_key=9b34e42a-5d05-4996-b07a-6a77c9a2d756", playerID];
    
    if(url == nil){
        return [NSString stringWithFormat: @"%@: %@", champIds[champId], @"UNRANKED"];
    }
    
    NSDictionary* data = [self getDataFrom:url];
    
    //NSLog(@"ALL DATA: %@", data);
    
    NSString* playerRank = @"";
    NSString* winPercentage = @"";
    
    NSArray* arr = data[playerID];
    
    for(int i = 0; i < [arr count]; i++){
        
        NSDictionary* d = arr[i];
        
        if([d[@"queue"] isEqualToString:@"RANKED_SOLO_5x5"]){
            playerRank = [playerRank stringByAppendingString: d[@"tier"]];
            playerRank = [playerRank stringByAppendingString: @" "];
            playerRank = [playerRank stringByAppendingString:d[@"entries"][0][@"division"]];
            
            
            float wins = [d[@"entries"][0][@"wins"] integerValue];
            float losses = [d[@"entries"][0][@"losses"] integerValue];
            winPercentage = [[NSString stringWithFormat:@"%f", wins/(wins+losses)] substringWithRange: NSMakeRange(2, 2)];
            
            break;
        }
        
    }
    
    if([playerRank isEqualToString:@""]){
        return [NSString stringWithFormat: @"%@: %@", champIds[champId], @"UNRANKED"];
    }
    
    return [NSString stringWithFormat: @"%@: %@, %@%@", champIds[champId], playerRank, winPercentage, @"%"];

    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}
- (BOOL) textFieldShouldReturn: (UITextField*) textField{
    
    [textField resignFirstResponder];
    [self showData];
    return YES;
    
}

//****************
//TABLE MAKING
//****************

-(NSInteger) numberOfSectionsInTableView: (UITableView*) tableView{
    return 1;
}
-(NSString*) tableView: (UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Enemy Team";
}
-(NSInteger) tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger*) section{
    return 5;
}
-(UITableViewCell*) tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
    }

    cell.textLabel.text = [enemies objectAtIndex:indexPath.row];
    
    return cell;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Row number %d touched", indexPath.row);
//}

//****************
//END TABLE MAKING
//****************



//make dictionary
NSString* readTextFile(NSString* name) {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:name
                                                     ofType:@"txt"];
    return [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
}

-(void) createChampIdDictionary{
    champIds = [[NSMutableDictionary alloc] init];
    NSString* text = readTextFile(@"LoLChampionIDs");
    NSArray* splitText = [text componentsSeparatedByString:@"\n"];
    for(NSString* s in splitText){
        NSArray* pair = [s componentsSeparatedByString:@","];
        champIds[pair[1]] = pair[0]; //ex. champIDs[@"266"] = @"Aatrox";
    }
    //NSLog(@"%@", champIds);
}





- (NSDictionary *) getDataFrom:(NSString *)url{
    //thanks StackOverflow!
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        //NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    
    NSError* error2;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:oResponseData
                                                         options:kNilOptions
                                                           error:&error2];

    
    return json;
}

@end
