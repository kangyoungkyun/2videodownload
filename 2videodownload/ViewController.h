//
//  ViewController.h
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@class DownloadProgressView;
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_videos;
    MPMoviePlayerController *mp;
}

@property (weak, nonatomic) IBOutlet UITableView *videoTable;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet DownloadProgressView *downloadProgressView;

@property (strong, nonatomic) NSArray *videos;

- (IBAction)refreshList:(id)sender;

@end

