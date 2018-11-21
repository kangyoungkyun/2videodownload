//
//  AstncDownloader.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "AstncDownloader.h"
#import "DownloadProgressView.h"
@implementation AstncDownloader


@synthesize targetFile;
@synthesize srcURL;
@synthesize outputHandle;
@synthesize tempFile;
@synthesize progressView;
@synthesize conn;


- (void)start{
    
    NSLog(@"AstncDownloader start 메소드 : 다운로드가 시작되었습니다-srcURL: %@" ,srcURL);
    //url 객체 생성
    NSURL *url = [NSURL URLWithString:srcURL];
    //요청 생성
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //연결 생성
    self.conn = [NSURLConnection connectionWithRequest:request
                                              delegate:self];
    
    [self.conn start];
}



//다운로드 할때 임시파일 이름 생성

-(NSString *)createUUID{
    
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    NSLog(@"AstncDownloader createUUID 메소드 : 임시파일 이름 %@" ,uuid);
    //9E5BFA9F-33F7-455F-8542-26D0880F378B
    return uuid;
    
    
}


#pragma mark NSURLConnectionDelegate Methods

- (NSURLRequest *) connection:(NSURLConnection *) connection
              willSendRequest:(nonnull NSURLRequest *)request
             redirectResponse:(nullable NSURLResponse *)response{
    
    NSLog(@"리다이렉트 리퀘스트 for %@ 리다이렉팅 to %@" ,srcURL, request.URL);
    /*
     리다이렉트 리퀘스트 for http://www.nasa.gov/sites/default/files/atoms/video/285_lightningacrosssolarsystem.mp4
     리다이렉팅 to http://www.nasa.gov/sites/default/files/atoms/video/285_lightningacrosssolarsystem.mp4
     */
    NSLog(@"all headers = %@" , [(NSHTTPURLResponse*) response allHeaderFields]);
    /*
     all headers = {
     Connection = "keep-alive";
     "Content-Length" = 0;
     Date = "Wed, 21 Nov 2018 01:37:35 GMT";
     Location = "https://www.nasa.gov/sites/default/files/atoms/video/285_lightningacrosssolarsystem.mp4";
     Server = "EdgePrism/4.6.1.0";
     }
     */
    return request;
}

/*
 이 델리게이트 메소드는 NSURLConnection이 서버에 연결되었을 때 호출된다.
 이것은 header를 가지는 response를 리턴한다.
 이 메소드는 여러번 호출된다. 그래서 매번 데이터가 호출될때 리셋해줘야 한다.
 */


-(void) connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response{
    
    NSLog(@"request url 로부터 응답 받음 %@" , srcURL);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSLog(@"all headers = %@" , [httpResponse allHeaderFields]);
    
    if (httpResponse.statusCode != 200) {
        if (downloadSize != 0L) {
            [progressView addAmountToDownload:-downloadSize];
            [progressView addAmountDownloaded:-totalDownloaded];
        }
        [connection cancel];
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (self.tempFile != nil) {
        [self.outputHandle closeFile];
        NSError *error;
        [fm removeItemAtPath:self.tempFile error:&error];
    }
    
    NSError *error;
    [fm removeItemAtPath:targetFile error:&error];
    
    //현재 디렉토리를 얻고, 임시파일 이름을 생성
    NSString *tempDir = NSTemporaryDirectory();
    self.tempFile = [tempDir stringByAppendingPathComponent:[self createUUID]];
    NSLog(@"컨텐츠가 %@ 이곳에 쓰여지고 있습니다." , self.tempFile);
    
    //private/var/mobile/Containers/Data/Application/F08270AC-6681-47B4-A8D5-12E57605EB8C/tmp/9E5BFA9F-33F7-455F-8542-26D0880F378B
    
    //임시파일을 생성하고 열기
    [fm createFileAtPath:self.tempFile contents:nil attributes:nil];
    self.outputHandle = [NSFileHandle fileHandleForWritingAtPath:self.tempFile];
    
    //prime the download progress view
    NSString *contentLengthString = [[httpResponse allHeaderFields]objectForKey:@"Content-length"];
    //144627421
    
    //다운로드 카운트 리셋
    if (downloadSize != 0L) {
        [progressView addAmountToDownload:-downloadSize];
        [progressView addAmountDownloaded:-totalDownloaded];
    }
    
    downloadSize = [contentLengthString longLongValue]; //long long으로 변환
    totalDownloaded = 0L;
    
    //총 다운받아야 될 수 셋팅!
    [progressView addAmountToDownload:downloadSize];

}


/*
 서버로부터 데이터 청크를 받았을때 호출된다.
 청크사이즈는 네트워크 타입과 서버 설정에 의해 결정된다.
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    
    totalDownloaded += [data length];
    
    NSLog(@"receidved %lld of %lld (%f%%) bytes of data for url %@",
          totalDownloaded,
          downloadSize,
          ((double)totalDownloaded/(double)downloadSize) *100.0,
          srcURL);
    
    [progressView addAmountDownloaded:[data length]];
    
    [self.outputHandle writeData:data];
}



-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"load fail with error %@ " , [error localizedDescription]);
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (self.tempFile != nil) {
        [self.outputHandle closeFile];
        NSError *error;
        [fm removeItemAtPath:self.tempFile error:&error];
    }
    
    //리셋 프로그레스 뷰
    if (downloadSize != 0L) {
        [progressView addAmountToDownload:-downloadSize];
        [progressView addAmountDownloaded:-totalDownloaded];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //파일 닫기
    [self.outputHandle closeFile];
    //타겟 위치로 파일 옮기기
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    //파일 이동
    [fm moveItemAtPath:self.tempFile
                toPath:self.targetFile
                 error:&error];
    
    //끝나면 완료 메소드 호출
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kDownloadComplete
     object:nil
     userInfo:nil];

}

@end
