//
//  TTPhotoViewController.h
//  PFCS
//
//  Created by flappybird on 16/8/4.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^FFPhotoHandler)(UIImage *image);

@interface FFPhotoViewController : UIViewController
@property(strong)FFPhotoHandler block;

@end
