//
//  ViewController.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "ViewController.h"
#import "FeedLoader.h"
#import "AstncDownloader.h"
#import "VideoCell.h"
#import "DownloadProgressView.h"
#import <MediaPlayer/MediaPlayer.h>


@interface ViewController ()

@end

@implementation ViewController
@synthesize videoTable;
@synthesize segmentedControl;
@synthesize downloadProgressView;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad 호출됨");
    
    [self refreshList:self];
    
    SEL showProgress = NSSelectorFromString(@"showProgress:");
    SEL hideProgress = NSSelectorFromString(@"hideProgress:");
    SEL downloadComplete = NSSelectorFromString(@"downloadComplete:");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:showProgress name:kShowProgressView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:hideProgress name:kHideProgressView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:downloadComplete name:kDownloadComplete object:nil];
   
    [self hideProgress:nil];
    
}

-(void)viewDidUnload{
    
    [self setVideoTable:nil];
    [self setSegmentedControl:nil];
    [self setDownloadProgressView:nil];
    [super viewDidUnload];
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark methods for extracting entry info

//비디오 url
-(NSString *)getVideoURL:(NSDictionary *)entry{
    NSLog(@"getVideoURL 호출됨");
    NSDictionary *enclosure = [entry objectForKey:@"enclosure"];
    NSString *url = [enclosure objectForKey:@"url"];
    return url;
}


//비디오 이름 얻기
-(NSString *) getVideoFilename:(NSDictionary *)entry{
    NSLog(@"getVideoFilename 호출됨");
    NSString *urlString = [self getVideoURL:entry];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *basePath = [url lastPathComponent];
    
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
    NSString *docPath = [pathList objectAtIndex:0];
    
    docPath = [docPath stringByAppendingPathComponent:basePath];
    
    return docPath;
    
}


-(BOOL) isFileDownloaded:(NSDictionary *)entry{
    NSString *docPath = [self getVideoFilename:entry];
    NSLog(@"isFileDownloaded 호출됨 : %@",docPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark UITableView Methods!

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"VideoCell";
    
    VideoCell *cell = (VideoCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"VideoCell" owner:self options:nil];
        cell = (VideoCell *)[nib objectAtIndex:0];
    }
    
    //*************** 최종 데이터가 여기로!! ***************
    NSDictionary *entry = [self.videos objectAtIndex:indexPath.row];
    
    //타이틀과 설명 얻기
    NSDictionary *titleDict = [entry objectForKey:@"title"];
    NSDictionary *descriptionDict = [entry objectForKey:@"description"];
    
    //셀설정
    id title = [titleDict objectForKey:@"text"];
    cell.titleLabel.text = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.descriptionLabel.text = [[descriptionDict objectForKey:@"text"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //다운로드 된 파일이면 체크마크표시
    if ([self isFileDownloaded:entry]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}


//행개수
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.videos count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 79.0;
}


//테이블에서 행이 선택되었을때
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"테이블에서 행이 선택되었습니다");
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *entry = [self.videos objectAtIndex:indexPath.row];
    
    if ([self isFileDownloaded:entry]) {
        NSURL *videoURL = [NSURL fileURLWithPath:[self getVideoFilename:entry]];
        mp = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
       // [mp shouldAutorotateToInterfaceOrientation:YES];
        [self presentMoviePlayerViewControllerAnimated:mp];
        
    } else {
        NSString *url = [self getVideoURL:entry];
        NSString *filename = [self getVideoFilename:entry];
        
        
        NSLog(@"없는파일, 다운로드 합니다.");
        NSLog(@"url: %@, filename: %@" , url, filename);
        
        AstncDownloader *downloader = [AstncDownloader new];
        
        downloader.srcURL = url;
        downloader.targetFile = filename;
        downloader.progressView = downloadProgressView;
        [downloader start];
    }
    
}


#pragma mark Action

- (IBAction)refreshList:(id)sender {
    NSLog(@"refreshList 버튼이 눌렸습니다.");
    //비디오 객체를 담을 빈 배열 준비
    self.videos = [NSArray array];
    
    //피드를 가져올 url 작성
    NSString *feedURL = @"http://www.nasa.gov/rss/NASAcast_vodcast.rss";
    
    //피드를 로드할 객체 생성
    FeedLoader *feedLoader = [FeedLoader new];
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //큐비동기 호출 feedLoader에서 커넥션 생성해서 응답과 데이터 받음 : 호출 후 setvideo메서드 호출
            [feedLoader doQueuedRequest:feedURL delegate:self];
            break;
        case 1:
            self.videos = [feedLoader doSyncRequest:feedURL];
            break;
            
        default:
            break;
    }

}


- (void) showProgress:(NSNotification *)notif{
    NSLog(@"showProgress 호출");
    [UIView animateWithDuration:0.2 animations:^{
       
        CGFloat height = downloadProgressView.frame.size.height;
        CGRect oldFrame = downloadProgressView.frame;
        CGRect nf = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - height, oldFrame.size.width, oldFrame.size.height);
        
        NSLog(@"height :%f" , height);
        
        downloadProgressView.frame = nf;
        
        oldFrame = videoTable.frame;
        
        nf =  CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height - height);
        
        videoTable.frame = nf;
        downloadProgressView.hidden = NO;
        
    }];
}


- (void) hideProgress:(NSNotification *)notif{
    NSLog(@"hideProgress 호출");
    [UIView animateWithDuration:0.2 animations:^{
        
        CGFloat height = downloadProgressView.frame.size.height;
        CGRect oldFrame = downloadProgressView.frame;
        
        CGRect nf = CGRectMake(oldFrame.origin.x, oldFrame.origin.y + height, oldFrame.size.width, oldFrame.size.height);
        
        NSLog(@"height :%f" , height);
        
        downloadProgressView.frame = nf;
        
        oldFrame = videoTable.frame;
        
        nf =  CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height + height);
        
        videoTable.frame = nf;
        downloadProgressView.hidden = YES;
        
    }];
}


-(void)downloadComplete:(NSNotification *) notif{
    [videoTable reloadData];
}




- (void)setVideos:(NSArray *)videos{
    NSLog(@"setVideos 호출");
    _videos = videos;
    [videoTable reloadData];
}

- (NSArray *) videos{
     NSLog(@"videos 호출");
    return _videos;
}





@end
