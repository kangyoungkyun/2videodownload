//
//  AstncDownloader.h
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kDownloadComplete @"downloadComplete"
//다운로드 프로그레스뷰를 사용할것임
@class DownloadProgressView;

@interface AstncDownloader : NSObject<NSURLConnectionDelegate>{
    long long downloadSize;
    
    long long totalDownloaded;
}


//DownloadProgressView 참조. 유저에게 진행상황 보여주기 위해서
@property (assign) DownloadProgressView *progressView;
//mp4파일
@property (strong) NSString *targetFile;
//다운로드를 위한 url
@property (strong) NSString *srcURL;
//콘텐츠가 쓰여진 파일 열기
@property (strong) NSFileHandle *outputHandle;
//파일은 다운로드 완료되면 타겟파일로 옮겨진다.
@property (strong) NSString *tempFile;
@property (strong) NSURLConnection *conn;

-(void)start;
@end
