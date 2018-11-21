//
//  XMLReader.h
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import <Foundation/Foundation.h>

//NSXMLParserDelegate를 구현한다.
@interface XMLReader : NSObject <NSXMLParserDelegate>{
    
    NSMutableArray *dictictionaryStack;
    NSMutableString *textInProgress;
    __autoreleasing NSError **errorPointer;
    
}

//클래스 메서드 작성
+(NSDictionary *)dictionaryForXMLData:(NSData *) data error:(NSError **)errorPointer;

+(NSDictionary *)dictionaryForXMLString:(NSString *) string error:(NSError **)errorPointer;


@end
