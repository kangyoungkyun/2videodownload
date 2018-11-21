//
//  DownloadProgressView.h
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//


#import <UIKit/UIKit.h>

#define kShowProgressView @"showProgressView"
#define kHideProgressView @"hideProgressView"

@interface DownloadProgressView : UIView{
    
    long long amountToDownload;
    long long amountDownloaded;
}

@property (weak,nonatomic) IBOutlet UIProgressView *progressBar;

@property (assign) BOOL hidden;

-(void) addAmountToDownload:(long long)amountToDownload;

-(void) addAmountDownloaded:(long long)amountDownloaded;

@end
