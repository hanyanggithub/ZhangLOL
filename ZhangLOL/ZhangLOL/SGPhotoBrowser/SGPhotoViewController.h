//
//  SGPhotoViewController.h
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "BaseViewController.h"
#import "SGPhotoView.h"

@interface SGPhotoViewController : BaseViewController

@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) SGPhotoView *photoView;
- (void)startShow;

@end
