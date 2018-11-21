//
//  FeedLoader.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "FeedLoader.h"
#import "XMLReader.h"
@implementation FeedLoader

static NSOperationQueue *queue;

//이메서드는 rss xml의 딕셔너리를 작동시키고, 피드안의 아이템 리스트를 리턴한다.
-(NSArray *)getEntriesArray:(NSDictionary *)dictionary {
    NSLog(@"getEntriesArray 메서드 호출");
    NSLog(@"rss: %@ ",[dictionary objectForKey:@"rss"]);
    NSLog(@"channel : %@",[[dictionary objectForKey:@"rss"]
                           objectForKey:@"channel"]);
    NSLog(@"item : %@",[[[dictionary objectForKey:@"rss"]
                         objectForKey:@"channel"]
                        objectForKey:@"item"]);
    
    
    
    /*
     출력결과
     {
     description =         {
     text = "\n California Wildfires Mapped from Space and more ...";
     };
     enclosure =         {
     length = 62336792;
     text = "\n ";
     type = "video/mp4";
     url = "http://www.nasa.gov/sites/default/files/atoms/video/nhq_2018_1117_this_week_nasa.mp4";
     };
     guid =         {
     isPermaLink = false;
     text = "\n http://www.nasa.gov/mediacast/this-week-nasa-november-17-2018";
     };
     link =         {
     text = "\n http://www.nasa.gov/mediacast/this-week-nasa-november-17-2018";
     };
     pubDate =         {
     text = "\n Sat, 17 Nov 2018 08:30 EST";
     };
     source =         {
     text = "\n NASACast Video";
     url = "http://www.nasa.gov/rss/dyn/NASAcast_vodcast.rss";
     };
     text = "\n";
     title =         {
     text = "\n  This Week @NASA, November 17, 2018";
     };
     },
     .....
     */
    
    
    
    NSArray *entries = [[[dictionary objectForKey:@"rss"]
                         objectForKey:@"channel"]
                        objectForKey:@"item"];
    
    // 메소드가 항상 배열을 리턴하게설정
    if (![entries isKindOfClass:[NSArray class]]) {
        entries = [NSArray arrayWithObjects:entries, nil];
    }
    
    return entries;
}


-(NSArray *)doSyncRequest:(NSString *)urlString{
    NSLog(@"doSyncRequest 메서드 호출");
    //문자로 부터 nsrul 객체 만든다.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //요청 생성
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:20.0];
    //요청을 보내고 응답 기다림
    NSHTTPURLResponse *response;
    NSError           *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    //에러 체크
    if (error != nil) {
        NSLog(@"doSync error on load = %@" , [error localizedDescription]);
        return nil;
    }
    
    
    //http 상태 체크
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            return nil;
        }
        NSLog(@"doSync headers : %@" , [httpResponse allHeaderFields]);
    }
    
    //데이터를 xml파서로 파싱해서 딕셔너리로 반환 받기
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data
                                                         error:&error];
    
    NSLog(@"doSync feed = %@" ,dictionary);
    
    NSArray *entries = [self getEntriesArray:dictionary];
    
    //피드에서 아이템 리스트 반환
    return entries;
}


//비동기 큐 요청. 요청이 완료될때, 이 메서드는 델리게이트 객체인 setVideo를 배열과 호출할 것이다.
//델리게이트는 뷰 컨트롤러
- (void)doQueuedRequest:(NSString *)urlString delegate:(id)delegate{
    NSLog(@"doQueuedRequest 메서드 호출");
    
    //url객체 생성
    NSURL *url = [NSURL URLWithString:urlString];
    //요청생성
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:20.0];
    
    //큐가 없으면 큐 생성
    
    if (queue == nil) {
        queue = [[NSOperationQueue alloc]init];
    }
    
    //커넥션 생성해서 응답과 데이터 받음
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error){
                               
                               if (error != nil) {
                                   NSLog(@"doQueue error on load = %@" , [error localizedDescription]);
                               }else{
                                   //http 상태 체크
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                       if (httpResponse.statusCode != 200) {
                                           return;
                                       }
                                       NSLog(@"doQueue headers : %@", [httpResponse allHeaderFields]);
                                   }
                                   
                                   NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data
                                                                                        error:&error];
                                   
                                   NSLog(@"doQueue feed = %@",dictionary);
                                   
                                   NSArray *entries = [self getEntriesArray:dictionary];
                                   
                                    //setVideos 메소드는 viewController에 정의되어있다.

                                   SEL selector = NSSelectorFromString(@"setVideos:");
                                   if ([delegate respondsToSelector:selector]){
                                        [delegate performSelectorOnMainThread:selector withObject:entries waitUntilDone:YES];
                                   }

                               }
                               
                               
                           }];
    
}






@end
