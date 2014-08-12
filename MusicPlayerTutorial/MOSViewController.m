//
//  MOSViewController.m
//  MusicPlayerTutorial
//
//  Created by Christina Mosnick on 8/5/14.
//  Copyright (c) 2014 Mosnick. All rights reserved.
//

#import "MOSViewController.h"

@interface MOSViewController ()

@property (weak, nonatomic) IBOutlet UIButton *togglePlayPause;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *durationOutlet;
@property (weak, nonatomic) IBOutlet UISlider *sliderOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *songsList;
@property (strong, nonatomic) AVPlayer *audioPlayer;

@end

@implementation MOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //1
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    //2 init audio player and retrieve songs from device
    self.audioPlayer = [[AVPlayer alloc] init];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    

        NSLog(@"ARRAY SIZE = %lu", (unsigned long)[itemsFromGenericQuery count]);
    self.songsList = [NSMutableArray arrayWithArray:itemsFromGenericQuery];
    //3
    [self.tableView reloadData];
    //4
    MPMediaItem *song = [self.songsList objectAtIndex:0];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self.audioPlayer play];
    //5
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    self.songName.text = songTitle;
    [self.sliderOutlet setMaximumValue:self.audioPlayer.currentItem.duration.value/self.audioPlayer.currentItem.duration.timescale];
    //6
    //NSLog(@"VIEWDIDLOAD!!!");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)togglePlayPauseTapped:(id)sender
{
    if(self.togglePlayPause.selected)
    {
        [self.audioPlayer pause];
        [self.togglePlayPause setSelected:NO];
    }
    else
    {
        [self.audioPlayer play];
        [self.togglePlayPause setSelected:YES];
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.songsList.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    MPMediaItem *song = [self.songsList objectAtIndex:indexPath.row];
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *durationLabel = [song valueForProperty: MPMediaItemPropertyGenre];
    cell.textLabel.text = songTitle;
    cell.detailTextLabel.text = durationLabel;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.audioPlayer pause];
    MPMediaItem *song = [self.songsList objectAtIndex:indexPath.row];
    AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    [self.audioPlayer play];
    [self.togglePlayPause setSelected:YES];
    MPMediaItem *currentSong = [self.songsList objectAtIndex:indexPath.row];
    NSString *songTitle = [currentSong valueForProperty: MPMediaItemPropertyTitle];
    self.songName.text = songTitle;
    [self.sliderOutlet setMaximumValue:self.audioPlayer.currentItem.duration.value/self.audioPlayer.currentItem.duration.timescale];
}

-(void) configurePlayer
{
    //7
    __block MOSViewController *weakSelf = self;
    //8
    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                   queue:NULL
                                              usingBlock:^(CMTime time)
    {
                                                  if(!time.value)
                                                  {
                                                      return;
                                                  }
                                                  
                                                  int currentTime = (int)((weakSelf.audioPlayer.currentTime.value)/weakSelf.audioPlayer.currentTime.timescale);
                                                  int currentMins = (int)(currentTime/60);
                                                  int currentSec  = (int)(currentTime%60);
                                                  
                                                  NSString * durationLabel =
                                                  [NSString stringWithFormat:@"%02d:%02d",currentMins,currentSec];
                                                  weakSelf.durationOutlet.text = durationLabel;
                                                  weakSelf.sliderOutlet.value = currentTime;
                                              }];
    
}

@end
