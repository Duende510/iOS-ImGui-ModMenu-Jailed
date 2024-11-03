#include "CustomWidgets.h"
#import "../Includes/SCLAlertView/SCLAlertView.h"
#import "../Includes/Obfuscate.h"
#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


void LightTheme()
{
  int lightBG[3] = { 214, 219, 226 };
  int lightChild[3] = { 230, 234, 238 };
  int lightIconChild[3] = { 248, 252, 255 };
  int lightInactiveText[3] = { 123, 133, 146 };
  int lightActiveText[3] = { 85, 85, 85 };
  int lightGrabColor[3] = { 210, 210, 210 };

  int darkBG[3] = { 17, 17, 19 };
  int darkChild[3] = { 22, 21, 26 };
  int darkIconChild[3] = { 25, 26, 31 };
  int darkInactiveText[3] = { 84, 82, 89 };
  int darkActiveText[3] = { 255, 255, 255 };
  int darkGrabColor[3] = { 72, 71, 78 };

  if (lightTheme)
  {
    for (int i = 0; i < 3; i++) {
      BGColor[i] = std::min(BGColor[i] + speed, lightBG[i]);
      ChildColor[i] = std::min(ChildColor[i] + speed, lightChild[i]);
      IconChildColor[i] = std::min(IconChildColor[i] + speed, lightIconChild[i]);
      InactiveTextColor[i] = std::min(InactiveTextColor[i] + speed, lightInactiveText[i]);
      ActiveTextColor[i] = std::min(ActiveTextColor[i] + speed, lightActiveText[i]);
      GrabColor[i] = std::min(GrabColor[i] + speed, lightGrabColor[i]);
    }
  }
  else {
    for (int i = 0; i < 3; i++) {
      BGColor[i] = std::max(BGColor[i] - speed, darkBG[i]);
      ChildColor[i] = std::max(ChildColor[i] - speed, darkChild[i]);
      IconChildColor[i] = std::max(IconChildColor[i] - speed, darkIconChild[i]);
      InactiveTextColor[i] = std::max(InactiveTextColor[i] - speed, darkInactiveText[i]);
      ActiveTextColor[i] = std::max(ActiveTextColor[i] - speed, darkActiveText[i]);
      GrabColor[i] = std::min(GrabColor[i] + speed, darkGrabColor[i]);
    }
  }
}

void ShowKeyboard(NSString* title, NSString* message, std::string& outString, BOOL allowOnlyNumbers)
{
    SCLAlertView *keyboardAlert = [[SCLAlertView alloc] initWithNewWindow];

    UITextField *inputField = [keyboardAlert addTextField:@"Custom Input"];
    inputField.layer.cornerRadius = 5.0f;
    inputField.borderStyle = UITextBorderStyleNone;
    inputField.keyboardType = allowOnlyNumbers ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    inputField.text = [NSString stringWithUTF8String:outString.c_str()];
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputField.backgroundColor = UIColorFromRGBA(ChildColor[0], ChildColor[1], ChildColor[2], 1.0);
    inputField.textColor = UIColorFromRGBA(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 1.0);

    [keyboardAlert addButton:NSSENCRYPT("Done") actionBlock:^{
        NSString *input = inputField.text;
        outString = std::string([input UTF8String]);
    }];

    keyboardAlert.shouldDismissOnTapOutside = YES;
    keyboardAlert.customViewColor = UIColorFromRGBA(ChildColor[0], ChildColor[1], ChildColor[2], 1.0);
    keyboardAlert.backgroundViewColor = UIColorFromRGBA(BGColor[0], BGColor[1], BGColor[2], 1.0);
    keyboardAlert.iconTintColor = UIColorFromRGBA(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 1.0);
    keyboardAlert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [keyboardAlert showEdit:title subTitle:message closeButtonTitle:nil duration:0.0];
}

void CopyToClipboard(const char* text)
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[NSString stringWithUTF8String:text]];
}

void saveSettings(const char* label, bool value) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:[NSString stringWithUTF8String:label]];
    [defaults synchronize];
}

bool loadSettings(const char* label, bool defaultValue) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:[NSString stringWithUTF8String:label]] != nil) {
        return [defaults boolForKey:[NSString stringWithUTF8String:label]];
    }
    return defaultValue;
}

bool ToggleWidget(const char* icon, const char* widgetName, bool* v, bool* newChildVisible)
{
    static std::map<std::string, bool> previousStates;
    std::string tabNameID = "##tabName_" + std::string(widgetName);
    std::string iconChildID = "##iconChild_" + std::string(widgetName);
    std::string toggleButtonID = "##toggle_" + std::string(widgetName);
    std::string settingsButtonID = "##settingsButton_" + std::string(widgetName);

    static std::map<std::string, bool> settingsButtonStates;
    if (settingsButtonStates.find(widgetName) == settingsButtonStates.end()) {
        settingsButtonStates[widgetName] = false;
    }
    bool stateChanged = false;

    ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], animation_text));
    ImGui::BeginChild(tabNameID.c_str(), ImVec2(ImGui::GetContentRegionAvail().x, 55), false, ImGuiWindowFlags_NoScrollbar);
    {
        ImVec2 currentPos = ImGui::GetCursorPos();
        ImGui::SetCursorPos(ImVec2(currentPos.x + 5, currentPos.y + 5));
        ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text));
        ImGui::BeginChild(iconChildID.c_str(), ImVec2(45, 45), false);
        {
            ImGui::SetWindowFontScale(0.6f);
            ImVec2 iconSize = ImGui::CalcTextSize(icon);
            ImVec2 iconPosition = ImVec2((45 - iconSize.x) * 0.5f, (45 - iconSize.y) * 0.5f);
            ImU32 iconColor = *v ? IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) : IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);
            ImGui::PushStyleColor(ImGuiCol_Text, iconColor);
            ImGui::SetCursorPos(iconPosition);
            ImGui::Text("%s", icon);
            ImGui::SetWindowFontScale(1.0f);
            ImGui::PopStyleColor(1);
        }
        ImGui::EndChild();
        ImGui::PopStyleColor(1);

        ImU32 textColor = *v ? IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) : IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);
        ImGui::PushStyleColor(ImGuiCol_Text, textColor);
        ImGui::SameLine();
        ImGui::SetCursorPosY(currentPos.y + 16);
        ImGui::Text("%s", widgetName);
        ImGui::PopStyleColor(1);

        ImGui::SameLine(ImGui::GetContentRegionAvail().x - 75);
        if (ToggleButton(toggleButtonID.c_str(), v)) {
            stateChanged = true;
        }

        if (previousStates[widgetName] != *v) {
            previousStates[widgetName] = *v;
            stateChanged = true;
            *newChildVisible = *v;
        }

        ImGui::SameLine(ImGui::GetContentRegionAvail().x - 20);

        float buttonOffsetY = -0.0f;
        ImGui::SetCursorPosY(currentPos.y + buttonOffsetY);
        const char* settingsIcon = settingsButtonStates[widgetName] ? ICON_FA_MINUS : ICON_FA_PLUS;

        ImGui::PushStyleColor(ImGuiCol_Button, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text));

        if (ImGui::Button(settingsButtonID.c_str(), ImVec2(20, 55))) {
            settingsButtonStates[widgetName] = !settingsButtonStates[widgetName];

            for (auto& pair : settingsButtonStates) {
                if (pair.first != widgetName) {
                    pair.second = false;
                    childVisibilityMap[pair.first] = false;
                } else {
                    childVisibilityMap[widgetName] = settingsButtonStates[widgetName];
                }
            }

            *newChildVisible = settingsButtonStates[widgetName];
            if (!settingsButtonStates[widgetName]) {
                childVisibilityMap[widgetName] = false;
            } else {
                childVisibilityMap[widgetName] = true;
            }
            ToggleAnimations = settingsButtonStates[widgetName];
        }

        ImGui::SetWindowFontScale(0.6f);
        ImVec2 buttonSize = ImGui::CalcTextSize(settingsIcon);
        ImVec2 buttonPos = ImVec2(ImGui::GetContentRegionAvail().x - 15, (55 - buttonSize.y) * 0.5f);
        ImGui::SetCursorPos(buttonPos);

        ImU32 settingsColor = settingsButtonStates[widgetName] ?
            IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) :
            IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);

        ImGui::PushStyleColor(ImGuiCol_Text, settingsColor);
        ImGui::Text("%s", settingsIcon);
        ImGui::PopStyleColor(1);

        ImGui::SetWindowFontScale(1.0f);

        ImGui::PopStyleColor(3);
    }
    ImGui::EndChild();
    ImGui::PopStyleColor(1);

    return stateChanged;
}

bool ToggleButton(const char* label, bool* v)
{
    ImVec2 p = ImGui::GetCursorScreenPos();
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    const float toggleWidth = 50.0f;
    const float toggleHeight = 25.0f;
    const float circleRadius = toggleHeight * 0.45f;

    int id = ImGui::GetID(label);

    static std::map<int, bool> toggleStates;
    static std::map<int, float> bounceProgress;
    static std::map<int, float> animationProgress;

    if (toggleStates.find(id) == toggleStates.end()) {
        toggleStates[id] = *v;
        animationProgress[id] = toggleStates[id] ? 1.0f : 0.0f;
    }

    float circlePosX = p.x + (toggleStates[id] ? toggleWidth - circleRadius : circleRadius);

    if (toggleStates[id]) {
        animationProgress[id] = ImMin(animationProgress[id] + 0.05f, 1.0f);
    } else {
        animationProgress[id] = ImMax(animationProgress[id] - 0.05f, 0.0f);
    }

    circlePosX = ImLerp(p.x + circleRadius, p.x + toggleWidth - circleRadius, animationProgress[id]);

    if (animationProgress[id] == 1.0f || animationProgress[id] == 0.0f) {
        bounceProgress[id] = ImMin(bounceProgress[id] + 0.1f, 1.0f);
    } else {
        bounceProgress[id] = ImMax(bounceProgress[id] - 0.1f, 0.0f);
    }

    float bounceOffsetX = bounceProgress[id] * 3.0f;
    circlePosX += (toggleStates[id] ? -bounceOffsetX : bounceOffsetX);

    ImU32 backgroundColor = (toggleStates[id]) ? IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text) : IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text);
    draw_list->AddRectFilled(ImVec2(p.x, p.y), ImVec2(p.x + toggleWidth, p.y + toggleHeight), backgroundColor, toggleHeight * 0.5f);

    ImU32 circleColor = (toggleStates[id]) ? IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) : IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);
    draw_list->AddCircleFilled(ImVec2(circlePosX, p.y + circleRadius + 1), circleRadius - 2.0f, circleColor);

    bool clicked = ImGui::InvisibleButton(label, ImVec2(toggleWidth, toggleHeight));

    if (clicked) {
        toggleStates[id] = !toggleStates[id];
        *v = toggleStates[id];
    }

    return clicked;
}


bool ToggleButtonMini(const char* label, bool* v)
{
    const float toggleWidth = 36.0f;
    const float toggleHeight = 18.0f;
    const float circleRadius = toggleHeight * 0.45f;
    const float gap = 5.0f;
    const float moveUpOffset = 0.0f;

    int id = ImGui::GetID(label);
    static std::map<int, bool> toggleStates;
    static std::map<int, float> bounceProgress;
    static std::map<int, float> animationProgress;

    if (toggleStates.find(id) == toggleStates.end()) {
        toggleStates[id] = *v;
        animationProgress[id] = toggleStates[id] ? 1.0f : 0.0f;
    }

    ImU32 textColor = toggleStates[id] ? IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) : IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);

    ImGui::PushStyleColor(ImGuiCol_Text, textColor);
    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);
    ImGui::TextUnformatted(label);
    ImGui::PopStyleColor();
    ImGui::SameLine();

    ImVec2 windowPos = ImGui::GetWindowPos();
    ImVec2 windowSize = ImGui::GetWindowSize();

    float toggleBackgroundX = windowPos.x + windowSize.x - toggleWidth - gap;
    float toggleBackgroundY = ImGui::GetCursorScreenPos().y - moveUpOffset;

    ImGui::SetCursorScreenPos(ImVec2(toggleBackgroundX, toggleBackgroundY));

    bool toggled = false;
    if (ImGui::InvisibleButton(label, ImVec2(toggleWidth, toggleHeight))) {
        toggleStates[id] = !toggleStates[id];
        *v = toggleStates[id];
        toggled = true;
    }

    if (toggleStates[id]) {
        animationProgress[id] = ImMin(animationProgress[id] + 0.04f, 1.0f);
    } else {
        animationProgress[id] = ImMax(animationProgress[id] - 0.04f, 0.0f);
    }

    float circlePosX = toggleBackgroundX + 6 + animationProgress[id] * (toggleWidth - circleRadius);
    if (toggleStates[id]) {
        circlePosX -= 4.0f;
    }

    if (animationProgress[id] == 1.0f || animationProgress[id] == 0.0f) {
        bounceProgress[id] = ImMin(bounceProgress[id] + 0.1f, 1.0f);
    } else {
        bounceProgress[id] = ImMax(bounceProgress[id] - 0.1f, 0.0f);
    }

    float bounceOffsetX = bounceProgress[id] * 3.0f;
    circlePosX += (toggleStates[id] ? -bounceOffsetX : bounceOffsetX);

    ImU32 backgroundColor = toggleStates[id] ? IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text) : IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text);
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    draw_list->AddRectFilled(ImVec2(toggleBackgroundX, toggleBackgroundY), ImVec2(toggleBackgroundX + toggleWidth, toggleBackgroundY + toggleHeight), backgroundColor, toggleHeight * 0.5f);

    ImU32 circleColor = toggleStates[id] ? IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text) : IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], animation_text);
    draw_list->AddCircleFilled(ImVec2(circlePosX, toggleBackgroundY + circleRadius + 1), circleRadius - 2.0f, circleColor);

    return toggled;
}


void SliderFloatMini(const char* label, float* v, float v_min, float v_max)
{
    const float sliderWidth = 100.0f;
    const float sliderHeight = 10.0f;
    const float gap = 5.0f;
    const float moveUpOffset = 0.0f;
    std::string sliderID = "##sliderID_" + std::string(label);

    int id = ImGui::GetID(label);

    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);

    ImU32 textColor = IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255);
    ImGui::PushStyleColor(ImGuiCol_Text, textColor);

    ImGui::TextUnformatted(label);

    ImGui::PopStyleColor();
    ImGui::SameLine();

    ImVec2 windowPos = ImGui::GetWindowPos();
    ImVec2 windowSize = ImGui::GetWindowSize();

    float sliderPosX = windowPos.x + windowSize.x - sliderWidth - gap;
    float sliderPosY = ImGui::GetCursorScreenPos().y - moveUpOffset;

    ImGui::SetCursorScreenPos(ImVec2(sliderPosX, sliderPosY));

    ImGui::SetNextItemWidth(sliderWidth);
    ImGui::SliderFloat(sliderID.c_str(), v, v_min, v_max);
}

void SliderIntMini(const char* label, int* v, int v_min, int v_max)
{
    const float sliderWidth = 100.0f;
    const float sliderHeight = 10.0f;
    const float gap = 5.0f;
    const float moveUpOffset = 0.0f;
    std::string sliderID = "##intSliderID_" + std::string(label);

    int id = ImGui::GetID(label);

    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);

    ImU32 textColor = IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255);
    ImGui::PushStyleColor(ImGuiCol_Text, textColor);

    ImGui::TextUnformatted(label);

    ImGui::PopStyleColor();
    ImGui::SameLine();

    ImVec2 windowPos = ImGui::GetWindowPos();
    ImVec2 windowSize = ImGui::GetWindowSize();

    float sliderPosX = windowPos.x + windowSize.x - sliderWidth - gap;
    float sliderPosY = ImGui::GetCursorScreenPos().y - moveUpOffset;

    ImGui::SetCursorScreenPos(ImVec2(sliderPosX, sliderPosY));

    ImGui::SetNextItemWidth(sliderWidth);
    ImGui::SliderInt(sliderID.c_str(), v, v_min, v_max);
}

void IntInputMini(const char* label, int* v, int v_min, int v_max)
{
    const float inputWidth = 100.0f;
    const float gap = 5.0f;
    const float labelOffset = 10.0f;
    const float verticalOffset = -18.0f;

    std::string intInputID = "##intInputID_" + std::string(label);

    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + gap);

    ImU32 textColor = IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255);
    ImGui::PushStyleColor(ImGuiCol_Text, textColor);

    ImGui::TextUnformatted(label);

    ImGui::PopStyleColor();

    float contentWidth = ImGui::GetContentRegionAvail().x;

    ImGui::SetCursorPosX(contentWidth - inputWidth - 5);

    ImGui::SetCursorPosY(ImGui::GetCursorPosY() + verticalOffset);

    ImGui::SetNextItemWidth(inputWidth);

    ImGui::InputInt(intInputID.c_str(), v, 1, 100, ImGuiInputTextFlags_CharsDecimal);

    if (*v < v_min) *v = v_min;
    if (*v > v_max) *v = v_max;
}

bool TextInputMini(const char* label, std::string& text, bool integerOnly)
{
    const float inputWidth = 100.0f;
    const float gap = 5.0f;
    const float verticalOffset = -18.0f;
    std::string textInputID = "##textInputID_" + std::string(label);

    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + gap);

    ImU32 textColor = IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255);
    ImGui::PushStyleColor(ImGuiCol_Text, textColor);

    ImGui::TextUnformatted(label);
    ImGui::PopStyleColor();

    float contentWidth = ImGui::GetContentRegionAvail().x;
    ImGui::SetCursorPosX(contentWidth - inputWidth - gap);
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() + verticalOffset);

    ImGui::SetNextItemWidth(inputWidth);

    ImGui::PushStyleColor(ImGuiCol_Button, ImGui::GetStyleColorVec4(ImGuiCol_FrameBg));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImGui::GetStyleColorVec4(ImGuiCol_FrameBg));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImGui::GetStyleColorVec4(ImGuiCol_FrameBg));

    if (ImGui::Button(text.c_str(), ImVec2(inputWidth, 20.0f)))
    {
        NSString* title = @"Custom Input";
        NSString* message = @"";
        ShowKeyboard(title, message, text, integerOnly);
    }

    ImGui::PopStyleColor(3);

    return false;
}

Console* Console::instance = nullptr;

std::string Console::getCurrentTime() {
  auto now = std::chrono::system_clock::now();
  std::time_t now_time = std::chrono::system_clock::to_time_t(now);
  std::tm* tm = std::localtime(&now_time);

  std::ostringstream oss;
  oss << std::put_time(tm, "%H:%M:%S");
  return oss.str();
}

void Console::logInternal(const std::string& text, bool printTime, int type) {
    Output output{text, printTime, type};
    if (printTime) {
        output.time = getCurrentTime();
    }
    outputArr.push_back(output);
}

void Console::renderLog(Output& output) {
    if (output.type != 0) return;
    std::string print = output.text;
    if (output.drawTime) print = "[" + output.time + "] " + print;
    ImGui::TextUnformatted(print.c_str());
}

void Console::renderLogError(Output& output) {
    if (output.type != 1) return;
    std::string print = output.text;
    if (output.drawTime) print = "[" + output.time + "] " ICON_FA_TIMES_CIRCLE " " + print;
    ImVec4 color = ImVec4(1.0f, 0.6f, 0.67f, 1.0f);

    ImGui::PushStyleColor(ImGuiCol_Text, color);
    ImGui::TextUnformatted(print.c_str());
    ImGui::PopStyleColor();
}

void Console::renderLogInfo(Output& output) {
    if (output.type != 2) return;
    std::string print = output.text;
    if (output.drawTime) print = "[" + output.time + "] " ICON_FA_INFO_CIRCLE " " + print;
    ImVec4 color = ImVec4(0.48f, 0.79f, 0.95f, 1.0f);

    ImGui::PushStyleColor(ImGuiCol_Text, color);
    ImGui::TextUnformatted(print.c_str());
    ImGui::PopStyleColor();
}

void Console::renderLogSuccess(Output& output) {
    if (output.type != 3) return;
    std::string print = output.text;
    if (output.drawTime) print = "[" + output.time + "] " ICON_FA_CHECK_CIRCLE " " + print;
    ImVec4 color = ImVec4(80.0f / 255.0f, 200.0f / 255.0f, 120.0f / 255.0f, 1.0f);

    ImGui::PushStyleColor(ImGuiCol_Text, color);
    ImGui::TextUnformatted(print.c_str());
    ImGui::PopStyleColor();
}

void Console::renderLogWarning(Output& output) {
    if (output.type != 4) return;
    std::string print = output.text;
    if (output.drawTime) print = "[" + output.time + "] " ICON_FA_EXCLAMATION_TRIANGLE " " + print;
    ImVec4 color = ImVec4(255.0f / 255.0f, 234.0f / 255.0f, 0.0f / 255.0f, 1.0f);

    ImGui::PushStyleColor(ImGuiCol_Text, color);
    ImGui::TextUnformatted(print.c_str());
    ImGui::PopStyleColor();
}

void Console::renderInternal() {
    if (!DRAW_CONSOLE) return;
    ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], animation_text));

    ImGui::BeginChild("Console", ImVec2(0, 200), true);

    ImVec2 titleBarSize = ImVec2(ImGui::GetContentRegionAvail().x, 25);
    ImVec2 titleBarPos = ImGui::GetCursorScreenPos();

    float rounding = 5.0f;
    ImGui::GetWindowDrawList() -> AddRectFilled(
      titleBarPos,
      ImVec2(titleBarPos.x + titleBarSize.x, titleBarPos.y + titleBarSize.y),
      IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text),
      rounding,
      ImDrawFlags_RoundCornersTop
    );

    std::string titleText = "Menu Logs";

    ImVec2 textSize = ImGui::CalcTextSize(titleText.c_str());

    float textX = titleBarPos.x + (titleBarSize.x - textSize.x) / 2.0f;
    ImGui::SetCursorScreenPos(ImVec2(textX, titleBarPos.y + (titleBarSize.y - textSize.y) / 2.0f));

    ImGui::TextUnformatted(titleText.c_str());
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 5);
    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);

    const float footer_height_to_reserve = ImGui::GetStyle().ItemSpacing.y + ImGui::GetFrameHeightWithSpacing();
    ImGui::BeginChild("ScrollingRegion", ImVec2(0, -footer_height_to_reserve), true);
    ImGui::SetWindowFontScale(0.9f);

    for (auto& output : outputArr) {
        if (selectedTypeTab == 0) {
            renderLog(output);
            renderLogError(output);
            renderLogInfo(output);
            renderLogSuccess(output);
            renderLogWarning(output);
        } else if (selectedTypeTab == 1) {
            renderLogError(output);
        } else if (selectedTypeTab == 2) {
            renderLogInfo(output);
        } else if (selectedTypeTab == 3) {
            renderLogSuccess(output);
        } else if (selectedTypeTab == 4) {
            renderLogWarning(output);
        }
    }

    if (ImGui::GetScrollY() >= ImGui::GetScrollMaxY()) ImGui::SetScrollHereY(1.0f);
    ImGui::SetWindowFontScale(1.0f);
    ImGui::EndChild();
    ImGui::Separator();

    bool reclaim_focus = false;
    ImGuiInputTextFlags input_text_flags = ImGuiInputTextFlags_EnterReturnsTrue;
    if (reclaim_focus) ImGui::SetKeyboardFocusHere(-1);

    ImGui::EndChild();
    ImGui::PopStyleColor();
}
