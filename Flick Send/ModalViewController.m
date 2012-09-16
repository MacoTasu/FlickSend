//
//  ModalViewController.m
//  Flick Send
//
//  Created by 志賀 誠 on 12/07/01.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import "ModalViewController.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//引き下げて更新の
- (void)scrollViewDidScroll:(UIScrollView *)sender {  
    
    CGFloat pageWidth = scrollView.frame.size.width;  
    pageControl.currentPage = scrollView.contentOffset.x /pageWidth;
}

- (void)viewDidLoad
{
    //スクロールとページコントロール
    subView=[[UIView alloc]initWithFrame:CGRectMake(0,44, 320, 480)];
    subView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:subView];
    subView.alpha=0.8;
    scrollView=[[UIScrollView alloc]init];
    scrollView.frame=subView.bounds;
    scrollView.contentSize=CGSizeMake(subView.frame.size.width*6,subView.frame.size.height);
    scrollView.pagingEnabled=YES;
    [subView addSubview:scrollView];
    
    
    for (int i=0; i<6; i++) {
        imageView=[[UIImageView alloc]init];
        imageView.frame=CGRectMake(subView.frame.size.width*i,0,subView.frame.size.width,subView.frame.size.height);
        imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"sample%d.png",i+1]];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
    }
    
    

    
    
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0,420,320, 20)];
    scrollView.delegate=self;
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.numberOfPages = 6;  
    pageControl.currentPage = 0;
    [subView addSubview:pageControl];
    
    [pageControl addTarget:self action:@selector(changePageControl:) forControlEvents:UIControlEventValueChanged];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//pagecontrolが切り替わった時の処理
- (void)changePageControl:(id)sender {
    
    // ページコントロールが変更された場合、それに合わせてページングスクロールビューを該当ページまでスクロールさせる
    CGRect frame = scrollView.frame;  
    frame.origin.x = frame.size.width * pageControl.currentPage;  
    frame.origin.y = 0;
    // 可視領域まで移動
    [scrollView scrollRectToVisible:frame animated:YES];  
    
}

- (IBAction)dismissAction:(id)sender{
        [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
