//
//  ModalViewController.h
//  Flick Send
//
//  Created by 志賀 誠 on 12/07/01.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController<UIScrollViewDelegate>{
    UIPageControl *pageControl;  
    UIView *subView;
    UIScrollView *scrollView;
    UIImageView *imageView;
}

- (IBAction)dismissAction:(id)sender;

@end
