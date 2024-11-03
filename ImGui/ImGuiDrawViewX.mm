#import "ImGuiDrawViewX.h"
#include "../Includes/Fonts/Fonts.hpp"
#include "../Menu.h"
#include "MenuUtils.h"

@interface ImGuiDrawViewX () <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@end

@implementation ImGuiDrawViewX

static BOOL menuVisible = YES;
extern MenuInteraction* menuTouchView;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];

        if (!_device) {
            abort();
        }

        [self setupImGuiContext];
    }

    return self;
}

- (void)setupImGuiContext {
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsDark();

    ImGuiIO& io = ImGui::GetIO();
    (void)io;

    [self addFontsToImGui:io];
    ImGui_ImplMetal_Init(_device);
}

- (void)addFontsToImGui:(ImGuiIO&)io {
    io.Fonts->Clear();

    ImFontConfig poppinsConfig;
    poppinsConfig.FontDataOwnedByAtlas = NO;
    io.Fonts->AddFontFromMemoryTTF((void*)poppinsFont, sizeof(poppinsFont), 18, &poppinsConfig);

    static const ImWchar iconsRanges[] = { ICON_MIN_FA, ICON_MAX_FA, 0 };
    ImFontConfig iconsConfig;
    iconsConfig.MergeMode = YES;
    iconsConfig.PixelSnapH = YES;
    iconsConfig.FontDataOwnedByAtlas = NO;
    io.Fonts->AddFontFromMemoryTTF((void*)fontAwesome, sizeof(fontAwesome), 18, &iconsConfig, iconsRanges);
}

+ (void)showChange:(BOOL)open {
    menuVisible = open;
}

+ (BOOL)isMenuShowing {
    return menuVisible;
}

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {
    CGRect frame = [UIScreen mainScreen].bounds; // Use screen bounds for view frame
    self.view = [[MTKView alloc] initWithFrame:frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
    self.mtkView.clipsToBounds = YES;
}

#pragma mark - Interaction

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self.view];

    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    io.MouseDown[0] = (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)drawInMTKView:(MTKView *)view {
    hideRecordTextfield.secureTextEntry = StreamerMode;

    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);

    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1.0f / (float)(view.preferredFramesPerSecond ?: 60);

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    [self updateUserInteractionEnabled];

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"iOSImGui"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        SetStyles();

        if (menuVisible) {

            ImGui::Begin("##Noname",  NULL, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoCollapse);
            MenuOrigin = ImGui::GetWindowPos();
            MenuSize = ImGui::GetWindowSize();
            LoadMenu();
            ImGui::End();
            //ImGui::ShowDemoWindow();
        }
        ImGui::EndFrame();
        ImGui::Render();
        ImDrawData *drawData = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)updateUserInteractionEnabled {
    BOOL isEnabled = menuVisible;
    [self.view setUserInteractionEnabled:isEnabled];
    [self.view.superview setUserInteractionEnabled:isEnabled];
    [menuTouchView setUserInteractionEnabled:isEnabled];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {

}

@end