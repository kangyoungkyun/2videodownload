//
//  XMLReader.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "XMLReader.h"

NSString *const kXMLReaderTextNodeKey = @"text";

@interface XMLReader (Internal)

-(id)initWithError:(NSError **)error;
-(NSDictionary *)objectWithData :(NSData *)data;

@end


@implementation XMLReader

#pragma mark public methods
//클래스 메서드 구현
+(NSDictionary *)dictionaryForXMLData:(NSData *) data error:(NSError **)errorPointer{
    NSLog(@"dictionaryForXMLData 호출");
    XMLReader *reader = [[XMLReader alloc] initWithError:errorPointer];
    NSDictionary *rootDictionary = [reader objectWithData:data];
    
    return rootDictionary;
    
}

+(NSDictionary *)dictionaryForXMLString:(NSString *) string error:(NSError **)errorPointer{
    NSLog(@"dictionaryForXMLString 호출");
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLString:data error:errorPointer];
}

#pragma mark parsing


//errorPointer를 NSError **로 초기화
- (id)initWithError:(NSError **)error{
    NSLog(@"XMLReader initWithError 호출");
    if (self = [super init]) {
        errorPointer = error;
    }
    return self;
}


- (NSDictionary *)objectWithData:(NSData *)data{
    NSLog(@"XMLReader objectWithData 호출");
    dictictionaryStack = [[NSMutableArray alloc] init];
    textInProgress = [[NSMutableString alloc] init];
    
    [dictictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    //parse the xml
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // 성공했을 경우 스텍의 루트 딕셔너리를 반환
    
    if (success) {
        NSDictionary *resultDict = [dictictionaryStack objectAtIndex:0];
        if (resultDict == nil) {
            NSLog(@"nil이야");
        } else {
            NSLog(@"있긴있어!");
        }
        return resultDict;
        
    }
    
    return nil;
}



//nsxmlparserDelegate 델리게이트 메서드
#pragma nsxmlparserDelegate methods
//시작태그

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
     NSLog(@"parser didStartElement 호출");
     NSLog(@"elementName : %@ , namespaceURI: %@ , qName : %@ ",elementName, namespaceURI, qName);
    
    //스텍안의 현재레벨의 딕셔너리 구하기
    NSMutableDictionary *parentDict = [dictictionaryStack lastObject];
    
    //새로운 엘리먼트를 위한 하위 딕셔너리 생성, 초기화
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    //이미 키를 위한 아이템이 존재한다면, 새로운 배열 생성해야함
    
    id existingValue = [parentDict objectForKey:elementName];
    
    if(existingValue){
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            //배열이 존재한다면, 사용
            array = (NSMutableArray *) existingValue;
        }else{
            //존재하지 않으면 생성
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            [parentDict setObject:array forKey:elementName];
        }
        
        //새로운 찰드 딕셔너리를 배열에 추가
        [array addObject:childDict];
    
    }else{
        
        //벨류값이 존재하지 않으면, 딕셔너리 업데이트
        [parentDict setObject:childDict forKey:elementName];

    }
    //스택 업데이트
    [dictictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
     NSLog(@"parser didEndElement 호출");
    
    NSLog(@"elementName : %@ , namespaceURI: %@ , qName : %@ ",elementName, namespaceURI, qName);
    
    //부모 딕셔너리를 textInfo로 업데이트
    NSMutableDictionary *dictInprogress = [dictictionaryStack lastObject];
    
    //텍스트 프로퍼티를 셋팅
    if ([textInProgress length] > 0) {
        [dictInprogress setObject:textInProgress forKey:kXMLReaderTextNodeKey];
        
        //reset the text
        textInProgress = [[NSMutableString alloc] init];
    }
    
    //현재 딕셔너리 제거
    [dictictionaryStack removeLastObject];
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"parser foundCharacters 호출 string : %@",string);
    //텍스트 값 빌드
    [textInProgress appendString:string];
}

//오류가 발생했을때
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    *errorPointer = parseError;
}




@end
