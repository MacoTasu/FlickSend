//
//  myCell.m
//  Flick Send
//
//  Created by 志賀 誠 on 12/03/17.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import "myCell.h"

@implementation myCell
@synthesize scr;
@synthesize label;
@synthesize views;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
