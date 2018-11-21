
1.appdelegate.h에 rootview controller 정의

2.xmlreader.h 작성(동기)
- NSXMLParserDelegate를 구현한다.


3.feedloader 작성(큐를 활용한 비동기)
#import "XMLReader.h"

마지막에 델리게이트는 setvideo호출
//setVideos 메소드는 viewController에 정의되어있다.



4-1 downloadprogressview uiview컨트롤 생성
호출하는 메서드
//kHideProgressView = hideProgress 메소드이다. viewController에 정의되어있다.
[[NSNotificationCenter defaultCenter] postNotificationName:kHideProgressView object:nil];

//kShowProgressView = showProgress 메소드이다. viewController에 정의되어있다.
[[NSNotificationCenter defaultCenter] postNotificationName:kShowProgressView  object:nil];


4-2 asyncDownloader 작성 (비동기)
먼저 downloadprogressview 임포트

//다운로드 프로그레스뷰를 사용할것임
@class DownloadProgressView;

<NSURLConnectionDelegate>사용

파일 닫을때 kDownloadComplete 메서드 호출 - viewcontroller에 정의 되어 있음. 테이블뷰 리로드 해줌
[[NSNotificationCenter defaultCenter]
postNotificationName:kDownloadComplete
object:nil
userInfo:nil];



5-1. 테이블 뷰 셀 만들기

5-2.뷰컨트롤러 만들기
#import <MediaPlayer/MediaPlayer.h>
@class DownloadProgressView;
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{





********************************************************************************


#.로직순서

1.앱을 실행시켰을때

*위치:viewDidLoad

[self refreshList:self];

*위치:refreshList

- 비디오 객체를 담을 빈 배열 준비
- 피드를 가져올 url 작성
- 피드를 로드할 객체 생성

* 피드로더
- 큐비동기 호출 : 델리게이트는 viewcontroller

- url객체 생성

- 요청생성

- 큐가 없으면 큐 생성

- 커넥션 생성해서 응답과 데이터 받음

- xmlreader객체의 dictionaryForXMLData를 이용해서 받은 데이터 넘겨줌

* 위치 : xmlReader

  //초기화
- [[XMLReader alloc] initWithError:errorPointer];

- NSDictionary *rootDictionary = [reader objectWithData:data];


- objectWithData 메소드에서
    배열, 스트링 초기화
    NSXMLParser 초기화
    Parser.delegate = self
    parser의 델리게이트 메소드 호출!
    성공했을경우 배열 리턴


*위치: 피드로더
- 피드로드에서 리턴된 딕셔너리 받고  getEntriesArray 메서드에 넘겨줌


- getEntriesArray에서 딕셔너리안의 키값을 이용해서 배열로만듬
NSArray *entries = [[[dictionary objectForKey:@"rss"]
objectForKey:@"channel"]
objectForKey:@"item"];

- 피드로드에서 viewcontroller에 작성한 setVideos 호출 :호출할때 배열데이터도 같이 넘겨줌


********* 이부분 계속 반복  파일이 있으면 테이블 뷰 행에 v 체크 없으면 넘어가기 ********************
(

videos 호출

isFileDownloaded 호출됨

getVideoFilename 호출됨

getVideoURL 호출됨


)





2. 해당 로우를 눌렀을때!


위치 : viewcontroller 의 didSelectRowAtIndexPath

video배열을 이용해서 클릭한 행의 dictionary 값을 얻는다.

isFileDownloaded 메소드를 이용해서 기기에 존재하는 파일인지 체크하기

있으면 동영상 재생

없으면 다운로드 진행


- 다운로드 진행

- video배열을이용해서 url과 filename얻기


AstncDownloader *downloader = [AstncDownloader new];

를 이용해서 파일 다운로드


*위치: AstncDownloader : start

- url 객체 생성
- 요청 생성
- 연결 생성

[con start]

- Connection 델리게이트 메소드 실행

1. willSendRequest


2. didReceiveResponse :request url 로부터 응답 받음

컨텐츠 쓸곳 지정
프로그래스바 총 다운로드 수 지정


3.didReceiveData 메서드 : 다운로드 진행
NSFileHandle 이용해서 파일쓰기
다운로드 진행될때 프로그래스바 셋팅

끝나면 등록한 notification 메소드 호출!
테이블 리로드





3. 동기적으로 호출

