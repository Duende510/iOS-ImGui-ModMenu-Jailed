#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#include <map>
#include <string>
#include "Menu.h"
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

bool showLogs = false;

//Color Scheme
int ChildColor[4] = { 22, 21, 26, 255 };
int BGColor[4] = { 17, 17, 19, 255 };
int IconChildColor[4] = { 25, 26, 31, 255 };
int InactiveTextColor[4] = { 84, 82, 89, 255 };
int ActiveTextColor[4] = { 255, 255, 255, 255 };
int GrabColor[4] = { 72, 71, 78, 255 };
bool lightTheme = false;

//Tab Vars
static int PageNumber = 0;
static bool sidebarTab0 = true, sidebarTab1 = false, sidebarTab2 = false, sidebarTab3 = false, sidebarTab4 = false;

//Child Tabs
std::map<std::string, bool> childVisibilityMap;

static int deepFadeAnimation = 255;
static bool animationEx = false;
static float animationButton = 25;
static float position = 25;
int animation_text = 255;
int speed = 10;

//Content Slide
static float columnOffset = 60.0f;
static float targetOffset = 60.0f;
float animationSpeed = 130.0f;
bool newChildVisible;
bool ToggleAnimations = false;

//Menu Icon
NSString *baseimage = @"";

void SetStyles(){
  ImGuiStyle* style = &ImGui::GetStyle();

  style->WindowBorderSize = 0;
  style->WindowMinSize = ImVec2(400, 260);
  style->FrameRounding = 5.0f;
  style->GrabRounding = 5.0f;
  style->WindowRounding = 5.0f;
  style->PopupRounding = 5.0f;
  style->ChildRounding = 5.0f;
  style->ScrollbarSize = 15;

  style->Colors[ImGuiCol_SeparatorHovered] = ImColor(0, 0, 0, 0);
  style->Colors[ImGuiCol_SeparatorActive] = ImColor(0, 0, 0, 0);
  style->Colors[ImGuiCol_Separator] = ImColor(0, 0, 0, 0);
  style->Colors[ImGuiCol_ButtonActive] =  ImColor(0, 0, 0, 0);
  style->Colors[ImGuiCol_ButtonHovered] = ImColor(0, 0, 0, 0);
  style->Colors[ImGuiCol_Button] =  ImColor(0, 0, 0, 0);

  style->Colors[ImGuiCol_WindowBg] = ImColor(BGColor[0], BGColor[1], BGColor[2], 255);
  style->Colors[ImGuiCol_FrameBg] = ImColor(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255);
  style->Colors[ImGuiCol_FrameBgHovered] = ImColor(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255);
  style->Colors[ImGuiCol_FrameBgActive] = ImColor(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255);

  style->Colors[ImGuiCol_TitleBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
  style->Colors[ImGuiCol_TitleBgActive] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
  style->Colors[ImGuiCol_Header] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
  style->Colors[ImGuiCol_HeaderHovered] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
  style->Colors[ImGuiCol_HeaderActive] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);
  style->Colors[ImGuiCol_ChildBg] = ImColor(ChildColor[0], ChildColor[1], ChildColor[2], 255);

  ImGui::PushStyleColor(ImGuiCol_WindowBg, IM_COL32(BGColor[0], BGColor[1], BGColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_FrameBg, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_FrameBgActive, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_Header, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_HeaderHovered, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_HeaderActive, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_TitleBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_TitleBgActive, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_SliderGrab, IM_COL32(GrabColor[0], GrabColor[1], GrabColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_SliderGrabActive, IM_COL32(GrabColor[0], GrabColor[1], GrabColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_ScrollbarGrab, IM_COL32(GrabColor[0], GrabColor[1], GrabColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_ScrollbarGrabActive, IM_COL32(GrabColor[0], GrabColor[1], GrabColor[2], 255));
  ImGui::PushStyleColor(ImGuiCol_ScrollbarGrabHovered, IM_COL32(GrabColor[0], GrabColor[1], GrabColor[2], 255));

}

void LoadMenu() {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Console::addLog("Welcome to ClientX v2.0");
  });

  ImVec2 P1, P2;
  ImDrawList * pDrawList;
  const auto & CurrentWindowPos = ImGui::GetWindowPos();
  const auto & pWindowDrawList = ImGui::GetWindowDrawList();
  ImDrawList * menuDrawList = ImGui::GetWindowDrawList();

  if (ToggleAnimations) {
    targetOffset = 0.0f;
  } else {
    targetOffset = 60.0f;
  }

  if (columnOffset != targetOffset) {
    float deltaTime = ImGui::GetIO().DeltaTime;
    if (columnOffset < targetOffset) {
      columnOffset += animationSpeed * deltaTime;
      if (columnOffset > targetOffset) columnOffset = targetOffset;
    } else {
      columnOffset -= animationSpeed * deltaTime;
      if (columnOffset < targetOffset) columnOffset = targetOffset;
    }
  }
  ImGui::Columns(2);
  ImGui::SetColumnOffset(1, columnOffset);

  ImGui::BeginChild("##SideBar", ImVec2(50, 255), true);
  {
    ImGui::SetCursorPos(ImVec2(13, 17));
    ImGui::PushStyleVar(ImGuiStyleVar_ButtonTextAlign, ImVec2(0.f, 0.f));

    if (sidebarTab0) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
    else
      ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));

    if (ImGui::Button(ICON_FA_USER "##Player", ImVec2(50, 30))) {
      PageNumber = 0;
      position = 25;
      if (!sidebarTab0) animationEx = true;
      if (!sidebarTab0) animation_text = 0;
      sidebarTab0 = true;
      sidebarTab1 = false;
      sidebarTab2 = false;
      sidebarTab3 = false;
      sidebarTab4 = false;
    };
    ImGui::PopStyleColor(1);

    ImGui::SetCursorPos(ImVec2(13, 68));
    if (sidebarTab1) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
    else
      ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));

    if (ImGui::Button(ICON_FA_LOCK "##Weapons", ImVec2(50, 30))) {
      PageNumber = 1;
      position = 75;
      if (!sidebarTab1) animationEx = true;
      if (!sidebarTab1) animation_text = 0;
      sidebarTab0 = false;
      sidebarTab1 = true;
      sidebarTab2 = false;
      sidebarTab3 = false;
      sidebarTab4 = false;
    };
    ImGui::PopStyleColor(1);

    ImGui::SetCursorPos(ImVec2(12, 118));
    if (sidebarTab2) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
    else
      ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));

    if (ImGui::Button(ICON_FA_CAR "##Cars", ImVec2(50, 30))) {
      PageNumber = 2;
      position = 125;
      if (!sidebarTab2) animationEx = true;
      if (!sidebarTab2) animation_text = 0;
      sidebarTab0 = false;
      sidebarTab1 = false;
      sidebarTab2 = true;
      sidebarTab3 = false;
      sidebarTab4 = false;
    };
    ImGui::PopStyleColor(1);

    ImGui::SetCursorPos(ImVec2(12, 168));
    if (sidebarTab3) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
    else
      ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));

    if (ImGui::Button(ICON_FA_SERVER "##Server", ImVec2(50, 30))) {
      PageNumber = 3;
      position = 175;
      if (!sidebarTab3) animationEx = true;
      if (!sidebarTab3) animation_text = 0;
      sidebarTab0 = false;
      sidebarTab1 = false;
      sidebarTab2 = false;
      sidebarTab3 = true;
      sidebarTab4 = false;
    };
    ImGui::PopStyleColor(1);

    ImGui::SetCursorPos(ImVec2(12, 218));
    if (sidebarTab4) ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(ActiveTextColor[0], ActiveTextColor[1], ActiveTextColor[2], animation_text));
    else
      ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));

    if (ImGui::Button(ICON_FA_COG "##Settings", ImVec2(50, 30))) {
      PageNumber = 4;
      position = 225;
      if (!sidebarTab4) animationEx = true;
      if (!sidebarTab4) animation_text = 0;
      sidebarTab0 = false;
      sidebarTab1 = false;
      sidebarTab2 = false;
      sidebarTab3 = false;
      sidebarTab4 = true;
    };
    ImGui::PopStyleColor(1);

    if (animationEx && deepFadeAnimation > 0) {
      deepFadeAnimation -= 8;
      if (deepFadeAnimation < 1) {
        animationButton = position;
        animationEx = false;
      }
    }

    if (!animationEx) {
      if (deepFadeAnimation < 255)
        deepFadeAnimation += 8;
    }

    if (animation_text <= 250) animation_text += 3;

    ImVec2 P1 = ImVec2(13, animationButton + 15);
    P1.x += CurrentWindowPos.x;
    P1.y += CurrentWindowPos.y;

    ImVec2 P2 = ImVec2(P1.x + 40, P1.y + 40);

    pDrawList = pWindowDrawList;
    pDrawList -> AddRectFilled(P1, P2, IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], deepFadeAnimation), 4.0f);
  }
  ImGui::EndChild();

  ImGui::NextColumn();
  ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(BGColor[0], BGColor[1], BGColor[2], 255));

  static float currentWidth = 0.0f;
  float targetWidth = ToggleAnimations ? ImGui::GetContentRegionAvail().x * 0.5f : ImGui::GetContentRegionAvail().x + 5;
  float animationSpeed = 5.0f;
  float deltaTime = ImGui::GetIO().DeltaTime;

  currentWidth += (targetWidth - currentWidth) * animationSpeed * deltaTime;

  if (fabs(targetWidth - currentWidth) < 0.01f) {
    currentWidth = targetWidth;
  }

  ImVec2 mainContentSize = ImVec2(currentWidth, 255);

  if (PageNumber == 0)
  {
    ImGui::BeginChild("##MainContent", mainContentSize, true);
    {
      newChildVisible = childVisibilityMap["Toggle 1"];
      ToggleWidget(ICON_FA_BOLT, "Toggle 1", & mods.bool1, & newChildVisible);
      childVisibilityMap["Toggle 1"] = newChildVisible;

      newChildVisible = childVisibilityMap["Toggle 2"];
      ToggleWidget(ICON_FA_CHILD, "Toggle 2", & mods.bool2, & newChildVisible);
      childVisibilityMap["Toggle 2"] = newChildVisible;

      newChildVisible = childVisibilityMap["Toggle 3"];
      ToggleWidget(ICON_FA_CHILD, "Toggle 3", & mods.bool3, & newChildVisible);
      childVisibilityMap["Toggle 3"] = newChildVisible;

    }
    ImGui::EndChild();
  }

  if (PageNumber == 2)
  {
    ImGui::BeginChild("##MainContent2", mainContentSize, true);
    {

    }
  }

  if (PageNumber == 3)
  {
    ImGui::BeginChild("##MainContent3", mainContentSize, true);
    {

    }
    ImGui::EndChild();
  }

  if (PageNumber == 4)
  {
    ImGui::BeginChild("##MainContent4", mainContentSize, true);
    {
      newChildVisible = childVisibilityMap["Light Theme"];
      if (ToggleWidget(ICON_FA_SUN, "Light Theme", & lightTheme, & newChildVisible))
      {
        Console::logSuccess("ClientX Theme Changed");
      }
      childVisibilityMap["Light Theme"] = newChildVisible;

      newChildVisible = childVisibilityMap["Streamer Mode"];
      if (ToggleWidget(ICON_FA_EYE_SLASH, "Streamer Mode", & StreamerMode, & newChildVisible))
      {

      }
      childVisibilityMap["Streamer Mode"] = newChildVisible;

      newChildVisible = childVisibilityMap["Menu Logs"];
      if (ToggleWidget(ICON_FA_TERMINAL, "Menu Logs", & showLogs, & newChildVisible))
      {

      }
      childVisibilityMap["Menu Logs"] = newChildVisible;
      if (showLogs)
      {
        Console::render();
      }

    }
    ImGui::EndChild();
  }

  for (const auto & pair: childVisibilityMap) {
    const std::string & widgetName = pair.first;
    bool isVisible = pair.second;

    if (isVisible) {
      ImGui::SameLine();
      ImGui::PushStyleColor(ImGuiCol_ChildBg, IM_COL32(ChildColor[0], ChildColor[1], ChildColor[2], animation_text));

      ImGui::BeginChild(("##newChild_" + widgetName).c_str(), ImVec2(ImGui::GetContentRegionAvail().x + 5, ImGui::GetContentRegionAvail().y), true);
      {
        ImVec2 titleBarSize = ImVec2(ImGui::GetContentRegionAvail().x, 25);
        ImVec2 titleBarPos = ImGui::GetCursorScreenPos();

        float rounding = 5.0f;
        ImGui::GetWindowDrawList() -> AddRectFilled(titleBarPos, ImVec2(titleBarPos.x + titleBarSize.x, titleBarPos.y + titleBarSize.y), IM_COL32(IconChildColor[0], IconChildColor[1], IconChildColor[2], animation_text), rounding, ImDrawFlags_RoundCornersTop);

        std::string titleText = widgetName + " Settings";
        ImVec2 textSize = ImGui::CalcTextSize(titleText.c_str());
        float textX = titleBarPos.x + (titleBarSize.x - textSize.x) / 2.0f;

        ImGui::SetCursorScreenPos(ImVec2(textX, titleBarPos.y + (titleBarSize.y - textSize.y) / 2.0f));
        ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(InactiveTextColor[0], InactiveTextColor[1], InactiveTextColor[2], 255));
        ImGui::Text("%s", titleText.c_str());
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 5);
        ImGui::SetCursorPosX(ImGui::GetCursorPosX() + 5);
        ImGui::SetWindowFontScale(0.8f);

        if (widgetName == "Toggle 1") {
          ImGui::Text(ICON_FA_INFO_CIRCLE);
          ImGui::SameLine();
          ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
          ImGui::Text("Toggle 1 description.");
          ImGui::PopTextWrapPos();
          ImGui::Spacing();

          bool toggleValue = false;
          ToggleButtonMini("Toggle A", & toggleValue);
          ToggleButtonMini("Toggle B", & toggleValue);
          ToggleButtonMini("Toggle C", & toggleValue);
          ImGui::Spacing();

          SliderFloatMini("SliderFloat", &mods.floatVal, 0.0f, 500.0f);
          SliderIntMini("SliderInt", &mods.intval, 0, 500);
          IntInputMini("IntInput", &mods.intval2, 0, 100);
          TextInputMini("TextInput", mods.myText, false);
        }
        else if (widgetName == "Menu Logs") {
          ImGui::Text(ICON_FA_INFO_CIRCLE);
          ImGui::SameLine();
          ImGui::PushTextWrapPos(ImGui::GetContentRegionAvail().x + 5);
          ImGui::Text("ClientX debug logs");
          ImGui::PopTextWrapPos();
        }
        ImGui::SetWindowFontScale(1.0f);
        ImGui::PopStyleColor();
      }
      ImGui::EndChild();
      ImGui::PopStyleColor();
    }
  }
  ImGui::Columns(1);
  LightTheme();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info)
{
  timer(5)
  {
    LoadMods();
  });
}

struct MyStruct {
  MyStruct() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  }
};
MyStruct mystruct;
