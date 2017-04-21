//
//  ImageBrowserViewController.m
//  ZhangLOL
//
//  Created by mac on 17/4/18.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "ImageBrowserController.h"
#import "SmallCellModel.h"
//#import <JavaScriptCore/JavaScriptCore.h>
//#import <WebKit/WebKit.h>
@interface ImageBrowserController ()

// <WKNavigationDelegate,WKUIDelegate>

//@property(nonatomic, strong)WKWebView *webView;

@property(nonatomic, copy)NSString *atlasTitle;
@property(nonatomic, copy)NSString *author;

@property(nonatomic, strong)UIView *titleBar;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UILabel *authorLabel;

@property(nonatomic, assign)BOOL isBarHidden;

@end

@implementation ImageBrowserController

// 1. 请求html页面代码使用正则表达式过滤获取图片的url（本地缓存html的可行方法）
// 2. 加载UIWebView或者WKWebView通过js交互获取图片的url
// 3. NSURLProtocol截获基于url loading system 的请求获取url

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTopBarBottomBar];
    [self methodOne];
}

- (void)createTopBarBottomBar {
    
    // top
    [self.customNaviBar setBackgroundImage:[UIImage imageNamed:@"navitransparentbg"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.customNaviBar];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 22, 40);
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny_normal"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"nav_btn_back_tiny__pressed"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.customNaviItem.leftBarButtonItem = leftItem;
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0, 0, 32, 32);
    [saveButton setImage:[UIImage imageNamed:@"share_btn_save_img_icon_normal"] forState:UIControlStateNormal];
    [saveButton setImage:[UIImage imageNamed:@"share_btn_save_img_icon_press"] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.customNaviItem.rightBarButtonItem = rightItem;
    
    // bottom
    self.titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bottom - self.view.height * 0.2, self.view.width, self.view.height * 0.2)];
    self.titleBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:self.titleBar];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.titleBar.width, 20)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.titleBar addSubview:self.titleLabel];
    
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.titleLabel.bottom + 5 , self.titleBar.width, 20)];
    self.authorLabel.textColor = [UIColor whiteColor];
    self.authorLabel.font = [UIFont systemFontOfSize:16];
    [self.titleBar addSubview:self.authorLabel];
    
}
- (void)saveButtonClicked {
    // 保存
    UIImageWriteToSavedPhotosAlbum(self.photoView.currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        MYLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD dismissWithDelay:0.5];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD dismissWithDelay:0.5];
    }
}
- (void)pop {
    [super pop];
    [self.navigationController popViewControllerAnimated:YES];
}
// 方法1
- (void)methodOne {
    // 加载html静态页面
    self.atlasTitle = self.cellModel.title;
    [ZhangLOLNetwork HTML:self.cellModel.article_url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *htmlCode = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (htmlCode) {
            // 正则匹配图片url
            self.imageUrls = [self regexImageUrls:htmlCode];
            // 作者
            self.author = [self regexAuthor:htmlCode];
            self.titleLabel.text = self.atlasTitle;
            self.authorLabel.text = self.author;
            // 显示图片
            [self showImage];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (NSArray *)regexImageUrls:(NSString *)htmlCode {
    
    NSMutableArray *listImage = [NSMutableArray array];
    // 匹配模式
    NSString *urlPattern = @"<img[^>]+?jason=[\"']?([^>'\"]+)[\"']?";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlPattern options:NSRegularExpressionCaseInsensitive error:&error];
    // match这块内容非常强大
    NSUInteger count = [regex numberOfMatchesInString:htmlCode options:NSMatchingReportCompletion range:NSMakeRange(0, [htmlCode length])];
    // 匹配到的次数
    if(count > 0){
        NSArray *matches = [regex matchesInString:htmlCode options:NSMatchingReportCompletion range:NSMakeRange(0, [htmlCode length])];
        
        for (NSTextCheckingResult *match in matches) {
            
            NSInteger count = [match numberOfRanges];
            // 匹配项
            for(NSInteger index = 0;index < count;index++){
                NSRange halfRange = [match rangeAtIndex:index];
                if (index == 1) {
                    // 拼接http协议
                    NSString *orgUrl = [htmlCode substringWithRange:halfRange];
                    orgUrl = [NSString stringWithFormat:@"http:%@",orgUrl];
                    [listImage addObject:orgUrl];
                }
            }
        }
        //遍历后可以看到三个range，1、为整体。2、为([\\w-]+\\.)匹配到的内容。3、(/?[\\w./?%&=-]*)匹配到的内容
        return listImage;
    }
    return nil;
}
- (NSString *)regexAuthor:(NSString *)htmlCode {
    NSString *author = nil;
    // 匹配模式
    // <div class="article_author">英雄联盟同人@Y-I-K-O </div>
    NSString *urlPattern = @"<div class=\"article_author\">.*?</div>";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlPattern options:NSRegularExpressionCaseInsensitive error:&error];
    // match这块内容非常强大
    NSUInteger count = [regex numberOfMatchesInString:htmlCode options:NSMatchingReportCompletion range:NSMakeRange(0, [htmlCode length])];
    // 匹配到的次数
    if(count > 0){
        NSArray *matches = [regex matchesInString:htmlCode options:NSMatchingReportCompletion range:NSMakeRange(0, [htmlCode length])];
        
        for (NSTextCheckingResult *match in matches) {
            
            NSInteger count = [match numberOfRanges];
            if (count!= 1) {
                return nil;
            }
            // 匹配项
            for(NSInteger index = 0;index < count;index++){
                NSRange halfRange = [match rangeAtIndex:index];
                NSString *div = [htmlCode substringWithRange:halfRange];
                // 再次匹配
                urlPattern = @">.*?<";
                regex = [NSRegularExpression regularExpressionWithPattern:urlPattern options:NSRegularExpressionCaseInsensitive error:&error];
                count = [regex numberOfMatchesInString:div options:NSMatchingReportCompletion range:NSMakeRange(0, [div length])];
                if (count > 0) {
                    NSArray *matches1 = [regex matchesInString:div options:NSMatchingReportCompletion range:NSMakeRange(0, [div length])];
                    for (NSTextCheckingResult *match1 in matches1) {
                        count = [match1 numberOfRanges];
                        
                        for(NSInteger index = 0;index < count;index++){
                            NSRange halfRange1 = [match1 rangeAtIndex:index];
                            NSString *result = [div substringWithRange:NSMakeRange(halfRange1.location + 1, halfRange1.length - 2)];
                            author = result;
                        }
                    }
                }
            }
        }
        //遍历后可以看到三个range，1、为整体。2、为([\\w-]+\\.)匹配到的内容。3、(/?[\\w./?%&=-]*)匹配到的内容
        return author;
    }
    return nil;
}


- (void)showImage {
    // 获取所有的图片url
    NSMutableArray *imageUrlArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.imageUrls.count; i++) {
        NSURL *thumbURL = [NSURL URLWithString:self.imageUrls[i]];
        [imageUrlArray addObject:thumbURL];
    }
    self.imageUrls = imageUrlArray;
    //  super
    [self startShow];
}

- (void)toggleBarState {
    [UIView animateWithDuration:0.35 animations:^{
        self.customNaviBar.alpha = self.isBarHidden;
        self.titleBar.alpha = self.isBarHidden;
        
    } completion:^(BOOL finished) {
        self.isBarHidden = !self.isBarHidden;
    }];
}




//// 方法2
//- (void)methodTwo {
//    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
//    self.webView.navigationDelegate = self;
//    [self.view addSubview:self.webView];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.cellModel.article_url]];
////    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
////    NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadRequest:request];
//}



//// 页面开始加载时调用
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//}
//// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    
//}
//// 页面加载完成之后调用 // 方法2
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    
//    NSString *js = @"var imgArray = document.getElementsByTagName('img'); var imgstr = ''; function f(){ for(var i = 0; i < imgArray.length; i++){ imgstr += imgArray[i].src;imgstr += ';';} return imgstr; } f();";
//    [webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        NSLog(@"%@,%@",result,error);
//        
//    }];
//}
//// 页面加载失败时调用
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
//    
//}



@end
