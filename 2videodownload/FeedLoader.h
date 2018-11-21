//
//  FeedLoader.h
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedLoader : NSObject

//동기 요청, 특정 url로딩
-(NSArray *) doSyncRequest:(NSString *)urlString;


//비동기 큐 요청. 요청이 완료될때, 이 메서드는 델리게이트 객체인 setVideo를 배열과 호출할 것이다.
-(void) doQueuedRequest:(NSString *)urlString delegate:(id)delegate;


@end
