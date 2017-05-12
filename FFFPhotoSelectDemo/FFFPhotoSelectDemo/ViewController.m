//
//  ViewController.m
//  FFFPhotoSelectDemo
//
//

#import "ViewController.h"
#import "FFPhotoViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectImage:(id)sender {
    FFPhotoViewController *vc = [[FFPhotoViewController alloc] init];
    vc.block = ^(UIImage *image){
        self.imageView.image = image;
    };
    [self presentViewController:vc animated:YES completion:nil];
}


@end
