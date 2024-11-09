#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#include "../ImGui/imgui.h"
#include "../ImGui/imgui_internal.h"
#include "../ImGui/imgui_impl_metal.h"

@interface ImGuiDrawViewX : UIViewController <MTKViewDelegate, UIKeyInput>

+ (void)showChange:(BOOL)open;
+ (BOOL)isMenuShowing;
- (void)updateIOWithTouchEvent:(UIEvent *)event;

@property (nonatomic, assign) BOOL isKeyboardVisible;

@end
