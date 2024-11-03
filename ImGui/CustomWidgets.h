#ifndef CustomWidgets_h
#define CustomWidgets_h
#include <vector>
#include <functional>
#include <string>
#include "imgui.h"
#include "imgui_internal.h"
#include "imgui_impl_metal.h"
#include "Includes/Fonts/Fonts.hpp"
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

using namespace std;

void LightTheme();
void ShowKeyboard(NSString* title, NSString* message, std::string& outString, BOOL allowOnlyNumbers);
void saveSettings(const char* label, bool value);
bool loadSettings(const char* label, bool defaultValue);
bool ToggleButton(const char* label, bool* v);
bool ToggleWidget(const char* icon, const char* widgetName, bool* v, bool* newChildVisible);
bool ToggleButtonMini(const char* label, bool* v);
void SliderFloatMini(const char* label, float* v, float v_min, float v_max);
void SliderIntMini(const char* label, int* v, int v_min, int v_max);
void IntInputMini(const char* label, int* v, int v_min, int v_max);
bool TextInputMini(const char* label, std::string& text, bool integerOnly);
void CopyToClipboard(const char* text);

extern int ChildColor[4];
extern int BGColor[4];
extern int IconChildColor[4];
extern int InactiveTextColor[4];
extern int ActiveTextColor[4];
extern int GrabColor[4];
extern int animation_text;
extern int speed;
extern bool ToggleAnimations;
extern bool lightTheme;
extern bool newChildVisible;
extern bool saveToggleStates;
extern std::map<std::string, bool> childVisibilityMap;

#pragma once

struct Output {
    std::string text, time;
    bool drawTime;
    int type;

    Output(std::string text_, bool drawTime_, int type_) {
        text = text_;
        drawTime = drawTime_;
        type = type_;
    }
};

class Console {
    static Console* instance;

    Console() = default;

    void logInternal(const std::string& text, bool printTime, int type);

    void renderLog(Output& output);
    void renderLogError(Output& output);
    void renderLogInfo(Output& output);
    void renderLogSuccess(Output& output);
    void renderLogWarning(Output& output);
    std::string getCurrentTime();

public:
    int selectedTypeTab;
    char inputBuf[256];
    std::vector<Output> outputArr;
    bool DRAW_CONSOLE = true;

    static Console& getInstance() {
        if (!instance) {
            instance = new Console();
        }
        return *instance;
    }

    static void addLog(const std::string& text, bool printTime = true) {
        getInstance().logInternal(text, printTime, 0);
    }

    static void logError(const std::string& text, bool printTime = true) {
        getInstance().logInternal(text, printTime, 1);
    }

    static void logInfo(const std::string& text, bool printTime = true) {
        getInstance().logInternal(text, printTime, 2);
    }

    static void logWarning(const std::string& text, bool printTime = true) {
        getInstance().logInternal(text, printTime, 4);
    }

    static void logSuccess(const std::string& text, bool printTime = true) {
        getInstance().logInternal(text, printTime, 3);
    }

    static void render() {
        getInstance().renderInternal();
    }

private:
    void renderInternal();
};

#endif
