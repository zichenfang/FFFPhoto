//
//  TTPhotoViewController.m
//  PFCS
//
//  Created by flappybird on 16/8/4.
//  Copyright © 2016年 PFCS. All rights reserved.
//

#import "FFPhotoViewController.h"
#import "FFPhotoCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>

#define FFDeviceWidth [UIScreen mainScreen].bounds.size.width
#define FFDeviceHeight [UIScreen mainScreen].bounds.size.height


#define itemRoom 4
#define itemWidth  (FFDeviceWidth-itemRoom*4)/3//左右留10空隙，cell之间留2空隙
#define itemHeight itemWidth

@interface FFPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong)UICollectionView *collectionView;
/**所有的相册*/
@property (nonatomic, strong) NSMutableArray *groupMutArr;
/**所有相册里的所有图片*/
@property (nonatomic, strong) NSMutableArray *imageArr;
/**ALAssetsLibrary*/
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, strong) NSMutableArray *groupName;

@property (nonatomic, strong) NSMutableArray *editingImages;

@end

@implementation FFPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];//
    flowLayout.itemSize = CGSizeMake(itemWidth,itemHeight);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, itemRoom, 0, itemRoom);
    flowLayout.minimumLineSpacing = itemRoom;
    flowLayout.minimumInteritemSpacing = itemRoom;
    //
    self.collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0,64, FFDeviceWidth,FFDeviceHeight-64) collectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    self.collectionView.showsVerticalScrollIndicator =YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UINib *nib = [UINib nibWithNibName:@"FFPhotoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"ffphoto"];
    

    
    self.assetsLibrary = [[ALAssetsLibrary alloc]init];
    self.groupMutArr = [NSMutableArray array];
    self.imageArr = [NSMutableArray array];
    self.groupName = [NSMutableArray array];
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            //NSLog(@"*****相册个数***%@",self.groupMutArr);
            [self.groupMutArr addObject:group];
            //每个相册的名字
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            [self.groupName addObject:groupName];
            NSMutableArray *images = [NSMutableArray array];
            [self.imageArr addObject:images];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                {
                    [images addObject:result];
                    //NSLog(@"*****所有相册里的所有图片****%@",self.imageArr);
                    //UIImage *image = [UIImage imageWithCGImage: result.thumbnail];
                    //NSString *type=[result valueForProperty:ALAssetPropertyType];
                }
            }];
        }
        
        [self.collectionView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"获取相册失败");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)camera:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机权限受限");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请在设备的设置-隐私-相机中允许访问相机。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted)
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                //设置拍照后的图片可被编辑
//                picker.allowsEditing = YES;
                picker.sourceType = sourceType;
                [self presentViewController:picker animated:YES completion:NULL];
            }
        }}];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera)//来自拍照
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        self.block([self imageCompressForWidth:originImage targetWidth:1024]);
    }
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.imageArr objectAtIndex:section] count];
    
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.imageArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"ffphoto";
    FFPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ALAsset *asset = [[self.imageArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.photoImgView.image  =[UIImage imageWithCGImage: asset.thumbnail];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [[self.imageArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (self.block) {
        [self dismissViewControllerAnimated:YES completion:nil];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGImageRef imgRef = [assetRep fullResolutionImage];
        UIImage *sourceImg =[UIImage imageWithCGImage:imgRef
                                                scale:assetRep.scale
                                          orientation:(UIImageOrientation)assetRep.orientation];
        
        self.block([self imageCompressForWidth:sourceImg targetWidth:1024]);
    }
}
-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
