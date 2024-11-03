#include "ImGuiDrawViewX.h"
#include "MenuUtils.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

@interface MenuUtils()
@property (nonatomic, strong) ImGuiDrawViewX *vna;
- (ImGuiDrawViewX*) GetImGuiView;
@end

static MenuUtils *extraInfo;
ImVec2 MenuOrigin = {(float)SCREEN_WIDTH - 400, 0};
ImVec2 MenuSize = {400, 260};

UIButton* InvisibleMenuButton;
UIButton* VisibleMenuButton;
MenuInteraction* menuTouchView;
UITextField* hideRecordTextfield;
UIView* hideRecordView;
bool StreamerMode = false;
bool MoveMenu = true;

extern NSString* baseimage; 

@interface MenuInteraction()
@end
@implementation MenuInteraction
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect touchableArea = CGRectMake(MenuOrigin.x, MenuOrigin.y, MenuSize.x, MenuSize.y);
    if (CGRectContainsPoint(touchableArea, point)) {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
@end


@implementation MenuUtils
bool isOpened = false;

- (ImGuiDrawViewX*) GetImGuiView
{
    return _vna;
}
+ (void)load
{
    [super load];
    timer(3){
        extraInfo =  [MenuUtils new];
        [extraInfo initTapGes];
    });
}
-(void)initTapGes
{
    UIView* mainView = [UIApplication sharedApplication].windows[0].rootViewController.view;

    hideRecordTextfield = [[UITextField alloc] init];
    hideRecordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    [hideRecordView setBackgroundColor:[UIColor clearColor]];
    [hideRecordView setUserInteractionEnabled:YES];
    hideRecordTextfield.secureTextEntry = true;
    [hideRecordView addSubview:hideRecordTextfield];
    CALayer *layer = hideRecordTextfield.layer;
    if ([layer.sublayers.firstObject.delegate isKindOfClass:[UIView class]]) {
        hideRecordView = (UIView *)layer.sublayers.firstObject.delegate;
    } else {
        hideRecordView = nil;
    }

    [[UIApplication sharedApplication].keyWindow addSubview:hideRecordView];

    if (!_vna) {
         ImGuiDrawViewX *vc = [[ImGuiDrawViewX alloc] init];
         _vna = vc;
    }

    [ImGuiDrawViewX showChange:false];
    [hideRecordView addSubview:_vna.view];

    menuTouchView = [[MenuInteraction alloc] initWithFrame:mainView.frame];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:menuTouchView];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:baseimage options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];

    InvisibleMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    InvisibleMenuButton.frame = CGRectMake(mainView.frame.size.width / 2, mainView.frame.size.height / 2, 50, 50);
    InvisibleMenuButton.backgroundColor = [UIColor clearColor];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragEnded:) forControlEvents:UIControlEventTouchUpInside];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragStarted:) forControlEvents:UIControlEventTouchDown];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [InvisibleMenuButton addGestureRecognizer:tapGestureRecognizer];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:InvisibleMenuButton];

    VisibleMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    VisibleMenuButton.frame = CGRectMake(mainView.frame.size.width / 2, mainView.frame.size.height / 2, 50, 50);
    VisibleMenuButton.backgroundColor = [UIColor clearColor];
    VisibleMenuButton.layer.cornerRadius = VisibleMenuButton.frame.size.width * 0.5f;
    [VisibleMenuButton setBackgroundImage:menuIconImage forState:UIControlStateNormal];
    VisibleMenuButton.layer.opacity = 0.7;
    [hideRecordView addSubview:VisibleMenuButton];
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            VisibleMenuButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];

        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            VisibleMenuButton.transform = CGAffineTransformIdentity;
        } completion:nil];

        [ImGuiDrawViewX showChange:![ImGuiDrawViewX isMenuShowing]];
    }
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);

    CGRect mainFrame = [UIApplication sharedApplication].windows[0].rootViewController.view.bounds;
    if (button.center.x < 0) button.center = CGPointMake(0, button.center.y);
    if (button.center.y < 0) button.center = CGPointMake(button.center.x, 0);
    if (button.center.y > mainFrame.size.height) button.center = CGPointMake(button.center.x, mainFrame.size.height);
    if (button.center.x > mainFrame.size.width) button.center = CGPointMake(mainFrame.size.width, button.center.y);

    VisibleMenuButton.center = button.center;
    VisibleMenuButton.frame = button.frame;
    VisibleMenuButton.layer.opacity = 1.0;
}

- (void)buttonDragStarted:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
        VisibleMenuButton.transform = button.transform;
    }];
}

- (void)buttonDragEnded:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformIdentity;
        VisibleMenuButton.transform = button.transform;
        VisibleMenuButton.layer.opacity = 0.7;
    }];
}

@end
