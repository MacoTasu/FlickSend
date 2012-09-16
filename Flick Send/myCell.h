//
//  myCell.h
//  Flick Send
//
//  Created by 志賀 誠 on 12/03/17.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface myCell : UITableViewCell

@property(nonatomic,retain)IBOutlet UIScrollView *scr;
@property(nonatomic,retain)IBOutlet UILabel *label;
@property(nonatomic,strong)UIImageView *views;

@end
