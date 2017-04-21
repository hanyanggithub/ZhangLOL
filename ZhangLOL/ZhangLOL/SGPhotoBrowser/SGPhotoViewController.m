//
//  SGPhotoViewController.m
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "SGPhotoViewController.h"
@interface SGPhotoViewController ()


@end

@implementation SGPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createSubviews];
    
}
- (void)createSubviews {
    self.photoView = [[SGPhotoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.photoView];
    __weak typeof (self)weakSelf = self;
    [self.photoView setSingleTapHandlerBlock:^{
        [weakSelf toggleBarState];
    }];

}
- (void)startShow {
    [self.photoView showImageWithUrls:self.imageUrls];
}
- (void)toggleBarState {
    
}


@end
