
//
//  MasterViewController.m
//  Flick Send
//
//  Created by 志賀 誠 on 12/03/17.
//  Copyright (c) 2012年 専修大学. All rights reserved.
//

#import "MasterViewController.h"

#define PHOTO_BLANK 25
#define PHOTO_W 106
#define PHOTO_H 90
#define pageNum 6

//どこからでもアクセス可能
@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end


@implementation MasterViewController


//Nibが準備された時の処理
- (void)awakeFromNib
{
    [super awakeFromNib];
}



//スクロールビューのスクロール時の処理
- (void)scrollViewDidScroll:(UIScrollView *)sender {  
    
    CGFloat pageWidth = scrollView.frame.size.width;  
    pageControl.currentPage = scrollView.contentOffset.x /pageWidth;

}  






//画面が読み込み完了になった時の処理
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    fullView=[[UIImageView alloc]init];
    views=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    views.backgroundColor=[UIColor blackColor];
    views.alpha=0.0;
    
    
    //BlueToothボタン
    lcustom = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [lcustom setBackgroundImage:[UIImage imageNamed:@"plus_@2x.png"]//個々の画像を変えるとボタンが変わる
                       forState:UIControlStateNormal];
    [lcustom addTarget:self action:@selector(bt:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* lbutton = [[UIBarButtonItem alloc] initWithCustomView:lcustom];
    self.navigationItem.leftBarButtonItem= lbutton;
    
    //navigationbarの名前
    [item setTitle:@"Flick Send"];
    
    //viewの背景画像
    back.backgroundColor =
    [UIColor colorWithPatternImage:[UIImage imageNamed:@"baclGourndImage.jpg"]];
    
    
    
    //Navigationbarの背景画像
    UIImage *image= [UIImage imageNamed:@"haikei.png"];
    if([self.navigationController.navigationBar
        respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        [self.navigationController.navigationBar setBackgroundImage:image
                                                      forBarMetrics:UIBarMetricsDefault];
    }
    
    
    //初期化
    if (!library) {
        library = [[ALAssetsLibrary alloc] init];
    }
    if (!rows) {
        rows = [[NSMutableArray alloc] init];
    } else {
        [rows removeAllObjects];
    }
    
    
    //ブロック構文で可変型配列のrowsにgroupを格納
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            [rows addObject:group];
        } else {
            [myTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"ERROR");
    };
    
    
    //取得するアルバム、イベント,写真　次の所で取得内容を記述
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent |ALAssetsGroupSavedPhotos;
    [library enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
    
    //Tableをdelegateに設定
    myTable.dataSource=self;
    myTable.delegate=self;
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"start"]==nil){
    
        //スクロールとページコントロール
        subView=[[UIView alloc]initWithFrame:CGRectMake(0,-10, 320, 480)];
        subView.backgroundColor=[UIColor blackColor];
        [self.view addSubview:subView];
        subView.alpha=0.8;
        scrollView=[[UIScrollView alloc]init];
        scrollView.frame=subView.bounds;
        scrollView.contentSize=CGSizeMake(subView.frame.size.width*pageNum,subView.frame.size.height);
        scrollView.pagingEnabled=YES;
        [subView addSubview:scrollView];
    
    
        for (int i=0; i<pageNum; i++) {
            imageView=[[UIImageView alloc]init];
            imageView.frame=CGRectMake(subView.frame.size.width*i,0,subView.frame.size.width,subView.frame.size.height);
            imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"sample%d.png",i+1]];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            [scrollView addSubview:imageView];
        }
    
    
        //初回起動時のみナビゲーションバーのボタンを隠す
        lcustom.hidden=YES;
        btn.hidden=YES;
    

    
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0,420,320, 20)];
        scrollView.delegate=self;
        pageControl.backgroundColor = [UIColor blackColor];
        pageControl.numberOfPages = 6;  
        pageControl.currentPage = 0;
        [subView addSubview:pageControl];
    
        [pageControl addTarget:self action:@selector(changePageControl:) forControlEvents:UIControlEventValueChanged];
    
        UIButton *closebtn=[[UIButton alloc]initWithFrame:CGRectMake(subView.frame.size.width*6-225,295, 150, 50)];
        [closebtn setBackgroundImage:[UIImage imageNamed:@"close@2x.png"] forState:UIControlStateNormal];
        [scrollView addSubview:closebtn];
    
        [closebtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void)close:(id)sender{
    [UIView beginAnimations:nil context:nil];  // 条件指定開始
    [UIView setAnimationDuration:0.3];  // 0.3秒かけてアニメーションを終了させる
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];  // アニメーションは
    
    lcustom.hidden=NO;
    subView.alpha=0.0;
    btn.hidden=NO;
    
    [UIView commitAnimations];  // アニメーション開始！
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"start"];
    [defaults synchronize];
    
    
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





- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


//tableViewの画面をreload
-(void)reload {
    [myTable reloadData];
}


#pragma mark - Table View

//セルをタップした時の反応　
/*　//今回は必要無
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/
//セクションの数＝イベントに応じて変化
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

//セルの高さ設定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}



//セルの行数設定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rows count];
}


//セルの要素、外部セル使用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Celldaze=@"Celldaze";
    myCell *cell = (myCell *)[tableView dequeueReusableCellWithIdentifier: Celldaze];
    if (cell == nil) {
        UIViewController *vc;
        vc=[[UIViewController alloc]initWithNibName:@"myCell" bundle:nil];
        cell=(myCell *)vc.view;
        
        
    }
    
    
    ALAssetsGroup *groupForCell;
    if(!groupForCell){
        groupForCell =[[ALAssetsGroup alloc]init];
        groupForCell = [rows objectAtIndex:indexPath.row];
    }else{
        groupForCell = [rows objectAtIndex:indexPath.row];
    }
        
    if (!assets) {
        assets = [[NSMutableArray alloc] init];
    } else {
        [assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [groupForCell setAssetsFilter:onlyPhotosFilter];
    [groupForCell enumerateAssetsUsingBlock:assetsEnumerationBlock];

    
    NSInteger count=assets.count-1;
    NSInteger x=0;
    if(1<assets.count){
        for(int i=assets.count-1; 0<i ; i--){
            ALAsset *asset = [assets objectAtIndex:i];
            UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
            cell.views=[[UIImageView alloc]initWithFrame:CGRectMake(0+x,25, PHOTO_W, PHOTO_H)];
            cell.scr.frame=cell.contentView.bounds;
            cell.views.image=thumbnail;
            cell.views.Tag=count;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTest:)];
            // タッチイベントを許可する
            cell.views.userInteractionEnabled = YES;
            
            // マルチタッチを有効にする。
            [cell.views setMultipleTouchEnabled:YES];
            [cell.views addGestureRecognizer:tap];
            
            cell.scr.contentSize =CGSizeMake((PHOTO_W+PHOTO_BLANK)*assets.count,PHOTO_H);
            cell.scr.scrollEnabled=YES;
            [cell.scr addSubview:cell.views];
            x=x+PHOTO_W+PHOTO_BLANK;
            count--;
        }
    }else if(assets.count==1){
            ALAsset *asset = [assets objectAtIndex:0];
            UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
            cell.views=[[UIImageView alloc]initWithFrame:CGRectMake(0+x,25, PHOTO_W, PHOTO_H)];
            cell.scr.frame=cell.contentView.bounds;
            cell.views.image=thumbnail;
            cell.views.Tag=count;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTest:)];
            // タッチイベントを許可する
            cell.views.userInteractionEnabled = YES;
            
            // マルチタッチを有効にする。
            [cell.views setMultipleTouchEnabled:YES];
            [cell.views addGestureRecognizer:tap];
            
            cell.scr.contentSize =CGSizeMake((PHOTO_W+PHOTO_BLANK)*assets.count,PHOTO_H);
            cell.scr.scrollEnabled=YES;
            [cell.scr addSubview:cell.views];
            x=x+PHOTO_W+PHOTO_BLANK;
            count--;    
    }
        
    cell.label.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    
    return cell;
}




#pragma mark - Gesture

-(void)gestureTest:(UIGestureRecognizer *)recognizer{
    NSLog(@"gestureTest[%@]",recognizer);
    NSLog(@"[%@]",recognizer.view);
    
    CGPoint loc = [recognizer locationInView:myTable];
    NSIndexPath* indexPath = [myTable indexPathForRowAtPoint:loc];
    //myCell* cell = (myCell*)[myTable cellForRowAtIndexPath:indexPath];
    NSLog(@"Index:%d",indexPath.row);
    NSLog(@"Tag:%d",recognizer.view.tag);
    
    ALAssetsGroup *groupForCell;
    if(!groupForCell){
        groupForCell =[[ALAssetsGroup alloc]init];
        groupForCell = [rows objectAtIndex:indexPath.row];
    }else{
        groupForCell = [rows objectAtIndex:indexPath.row];
    }
    
    
    if (!assets) {
        assets = [[NSMutableArray alloc] init];
    } else {
        [assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [assets addObject:result];
        }
    };
    
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];//すべての写真
    [groupForCell setAssetsFilter:onlyPhotosFilter];
    [groupForCell enumerateAssetsUsingBlock:assetsEnumerationBlock];//ブロック構文
    ALAsset *asset = [assets objectAtIndex:recognizer.view.tag];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                       scale:[representation scale]
                                 orientation:[representation orientation]];
    fullView.image=fullScreenImage;
    fullView.frame=CGRectMake(0,views.frame.origin.y+18, 320,400);
    fullView.alpha=0.0;
    fullView.contentMode=UIViewContentModeScaleAspectFit;
    // シングルタップ  
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    fullView.userInteractionEnabled = YES;
    views.userInteractionEnabled = YES;
    // マルチタッチを有効にする。
    fullView.multipleTouchEnabled=YES;
    views.multipleTouchEnabled=YES;
    
    
    
    //縦スワイプ
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpGesture:)];  
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp; 
    
    
    [views addGestureRecognizer:swipeUpGesture];  
    [fullView addGestureRecognizer:swipeUpGesture];

    
    
    
    
    
    [fullView addGestureRecognizer:tapGesture];
    [views addGestureRecognizer:tapGesture];
    
    
    [self.view addSubview:views];
    [views addSubview:fullView];
    
    
    [UIView beginAnimations:nil context:nil];  // 条件指定開始
    [UIView setAnimationDuration:0.3];  // 0.3秒かけてアニメーションを終了させる
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];  // アニメーションは
    fullView.alpha=1.0;
    views.alpha=1.0;
    rcustom.alpha=0.0;
    
    [UIView commitAnimations];  // アニメーション開始！
    
    
    
    //  [self performSegueWithIdentifier:@"move" sender:self];
    
}


-(void)handleTapGesture:(id)sender{
    
    
    [UIView beginAnimations:nil context:nil];  // 条件指定開始
    [UIView setAnimationDuration:0.3];  // 0.3秒かけてアニメーションを終了させる
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];  // アニメーション
    
    fullView.alpha=0.0;
    views.alpha=0.0;  
    rcustom.alpha=1.0;
    
    [UIView commitAnimations];  // アニメーション開始
    NSLog(@"FullImage:%@,%@",fullView,views);


}




#pragma BlueTooth

-(void)bt:(id)sender{
    
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    
    //通信タイプを選択。Onlineはネットワークを利用するので今回はNearby
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;      
    [picker show];
    
    
}



//相手からデータがおくられてきた時の処理
- (void) receiveData:(NSData *)data 
            fromPeer:(NSString *)peer 
           inSession:(GKSession *)session 
             context:(void *)context {
    
    
   //lacal notification 
   /* //UILocalNotificationクラスのインスタンスを作成します。
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    //通知を受け取る時刻を指定します。ここでは、現在の時間から１０秒後を指定しています。
    localNotif.fireDate = [[NSDate date] addTimeInterval:3];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    //通知メッセージの本文を指定します。
    localNotif.alertBody = [NSString stringWithFormat:@"画像を受信しました。"];
    
    //通知メッセージアラートのボタンに表示される文字を指定します。
    localNotif.alertAction = @"";
    
    //通知されたときの音を指定します。
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    //通知を受け取るときに送付される NSDictionary を作成します。
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"画像を受信しました。" forKey:@"EventKey"];
    localNotif.userInfo = infoDict;
    
    //作成した通知イベント情報をアプリケーションに登録します。
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];*/
    
    
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:@"画像を受信しました。"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil];
    [alert show];

    
    
    UIImage* image = [[UIImage alloc] initWithData:data];
    
    
    
    // 付加情報の作成
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
    NSDictionary *exif = [NSDictionary dictionaryWithObjectsAndKeys:
                          nil, (NSString *)kCGImagePropertyExifUserComment,nil];
    [metaData setObject:exif forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    // 写真に付加情報を付けて書き込み実行
    ALAssetsLibrary *libraries = [[ALAssetsLibrary alloc] init];
    [libraries writeImageToSavedPhotosAlbum:image.CGImage	
                                 metadata:metaData
                          completionBlock:^(NSURL* url, NSError* error){
                              NSLog(@"Save Finish: %@<%@>", url, error);
                          }
     ];
    
}

- (void)alertView:(UIAlertView*)alertView 
didDismissWithButtonIndex:(NSInteger)index {
    NSLog(@"test");
    
    //初期化
    if (!library) {
        library = [[ALAssetsLibrary alloc] init];
    }
    if (!rows) {
        rows = [[NSMutableArray alloc] init];
    } else {
        [rows removeAllObjects];
    }
    
    
    //ブロック構文で可変型配列のrowsにgroupを格納
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            [rows addObject:group];
        } else {
            [myTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"ERROR");
    };

    
    //取得するアルバム、イベント,写真　次の所で取得内容を記述
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent |ALAssetsGroupSavedPhotos;
    [library enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];

    
}



//上スワイプで画像を送信する処理
- (void) handleSwipeUpGesture:(UISwipeGestureRecognizer *)sender {  
    NSLog(@"Up");  
    
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation( fullView.image )];
    if (currentSession){
        if(pngData!=nil){
            
            [currentSession sendDataToAllPeers:pngData
                                  withDataMode:GKSendDataReliable 
                                         error:nil];
            
            
            [UIView beginAnimations:nil context:nil];  // 条件指定開始
            [UIView setAnimationDuration:0.5];  // 0.5秒かけてアニメーションを終了させる
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];  // アニメーションは
            fullView.center=CGPointMake(views.center.x, views.frame.origin.y-300);
            views.alpha=0.0;
            rcustom.alpha=1.0;
            [UIView commitAnimations];  // アニメーション開始！
            
        
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接続先を選んで下さい" 
                                                        message:nil
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];  
    }

    
}

//BlueToothキャンセル時の処理 初期化
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)pickers
{
    pickers.delegate = nil;
    NSLog(@"cancel");
    
}

//相手との接続が成功,失敗時のレシーバ
- (void)session:(GKSession *)session 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state {
    
    if(state==GKPeerStateConnected){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接続成功" 
                                                        message:nil
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];  
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接続失敗" 
                                                        message:@"もう一度つないでください。"
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];  
        currentSession = nil;
    }
    
}


//通信を可能にする
- (void)peerPickerController:(GKPeerPickerController *)pickers 
              didConnectPeer:(NSString *)peerID 
                   toSession:(GKSession *) session {
    currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    pickers.delegate = nil;
    
    [pickers dismiss];

}


@end
