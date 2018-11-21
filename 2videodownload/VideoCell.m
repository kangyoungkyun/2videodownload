//
//  VideoCell.m
//  2videodownload
//
//  Created by MacBookPro on 20/11/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

@synthesize titleLabel;
@synthesize descriptionLabel;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //초기화 코드
    }
    return self;
}

@end
