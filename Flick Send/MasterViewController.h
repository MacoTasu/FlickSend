//
//  MasterViewController.h
//  Flick Send
//
//  Created by 志賀 誠 on 12/03/17.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <GameKit/GameKit.h>
#import "myCell.h"



@interface MasterViewController : UIViewController<UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,GKPeerPickerControllerDelegate,GKSessionDelegate>{
    
    NSMutableArray *rows;
    NSMutableArray *assets;
    ALAssetsLibrary *library;
    ALAssetsGroup *asGroup;
    UIImageView *fullView;
    UIView *views;
    UIButton *rcustom;
    UIButton *lcustom;
    IBOutlet UINavigationItem *item;
    IBOutlet UIView *back;
    IBOutlet UITableView *myTable;
    IBOutlet UIButton *btn;
    
    GKPeerPickerController *picker;
    GKSession *currentSession;

    UIPageControl *pageControl;  
    UIView *subView;
    UIScrollView *scrollView;
    UIImageView *imageView;
    
    
    
}

@end