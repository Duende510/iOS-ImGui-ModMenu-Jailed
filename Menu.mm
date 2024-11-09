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
NSString *baseimage = @"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";

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

  if (PageNumber == 1)
  {
    ImGui::BeginChild("##MainContent1", mainContentSize, true);
    {

    }
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
