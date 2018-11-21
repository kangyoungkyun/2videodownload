//
//  DownloadProgressView.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "DownloadProgressView.h"

@implementation DownloadProgressView
@synthesize progressBar;
@synthesize hidden;

-(id)initWithFrame:(CGRect)frame{
    NSLog(@"DownloadProgressView initWithFrame 초기화 메서드 호출됨");
    self = [super initWithFrame:frame];
    if (self) {
        //초기화 코드
    }
    return self;
}

-(void) adjustProgressBar {
    NSLog(@"adjustProgressBar 메서드 호출됨");
    float progress = (float)amountDownloaded / (float)amountToDownload;
    
    [progressBar setProgress:progress animated:YES];
    
    //다운로드 된 수 : , 총 다운로드 수
    NSLog(@"downloaded : %lld to download: %lld" ,amountDownloaded,amountToDownload);
    
    //다운로드 된 수와 총 다운로드수가 같으면 프로그래스바를 숨긴다.
    if (amountDownloaded == amountToDownload) {
        //kHideProgressView = hideProgress 메소드이다. viewController에 정의되어있다.
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideProgressView object:nil];
        NSLog(@"adjustProgressBar에서 kHideProgressView 메서드 호출함");
        self.hidden = true;
        //값은 초기화 해준다.
        amountToDownload = 0L;
        amountDownloaded = 0L;
        
        //다운로드 된 수와 총 다운로드수가 다르면 : 아직 다운완료 안됐으면!
    }else if(self.hidden){
        //kShowProgressView = showProgress 메소드이다. viewController에 정의되어있다.
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowProgressView  object:nil];
        NSLog(@"adjustProgressBar에서 kShowProgressView 메서드 호출함");
    }
    
}


-(void) addAmountToDownload:(long long)atd{
    NSLog(@"addAmountToDownload 메서드 호출됨");
    @synchronized(self){
        amountToDownload += atd;
    }
    [self adjustProgressBar];
}

-(void) addAmountDownloaded:(long long)ad{
    NSLog(@"addAmountDownloaded 메서드 호출됨");
    @synchronized(self){
        amountDownloaded += ad;
    }
    [self adjustProgressBar];
}



@end
