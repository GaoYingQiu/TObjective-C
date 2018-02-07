//
//  HHWeiboCellContentBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "ReactiveCocoa.h"
#import "UIButton+WebCache.h"

#import "HHFoundation.h"
#import "CTMediator+Web.h"

#import "HHWeiboCellContentBinder.h"
#import "HHWeiboCellContentViewModelProtocol.h"

@interface HHWeiboCellContentBinder ()<MWPhotoBrowserDelegate>

@property (nonatomic, strong) UIView<HHWeiboCellContentViewProtocol> *view;
@property (nonatomic, strong) id<HHWeiboCellContentViewModelProtocol> viewModel;

@property (nonatomic, strong) RACCommand *imageButtonCommand;
@end

@implementation HHWeiboCellContentBinder

- (instancetype)initWithView:(UIView<HHWeiboCellContentViewProtocol> *)view {
    if (self = [super init]) {
        self.view = view;
        
        RAC(view.textLabel, attributedText) = RACObserve(self, viewModel.text);
        for (UIButton *imageButton in view.imageButtons) {
            imageButton.rac_command = self.imageButtonCommand;
        }
    }
    return self;
}

- (void)bind:(id<HHWeiboCellContentViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    UIView<HHWeiboCellContentViewProtocol> *view = self.view;
    [view.imageButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull imageButton, NSUInteger idx, BOOL * _Nonnull stop) {
        
        imageButton.hidden = (idx >= viewModel.imageUrls.count);
        if (!imageButton.isHidden) {
            [imageButton sd_setImageWithURL:viewModel.imageUrls[idx] forState:UIControlStateNormal placeholderImage:[UIColor colorWithHex:0xe5e5e5].image];
        }
    }];
    [viewModel setOnClickHrefHandler:^(HHWeiboHrefType type, NSString *href) {
        switch (type) {
            case HHWeiboHrefURL: {
                [CTRouter pushToWebVCWithURL:href title:@"XxX"];
            }   break;
                
            default: { NSLog(@"%@", href); } break;
        }
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.viewModel.largeImageUrls.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return self.viewModel.largeImageUrls[index];
}

#pragma mark - Action

- (RACCommand *)imageButtonCommand {
    if (!_imageButtonCommand) {
        @weakify(self);
        _imageButtonCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *sender) {
            @strongify(self);
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            [browser setCurrentPhotoIndex:sender.tag];
            [self.view.navigationController pushViewController:browser animated:YES];
            return [RACSignal empty];
        }];
    }
    return _imageButtonCommand;
}

@end
