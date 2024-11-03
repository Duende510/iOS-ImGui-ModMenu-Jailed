#ifndef Menu_h
#define Menu_h
#include <vector>
#include <functional>
#include <string>
#include "ImGui/imgui.h"
#include "ImGui/imgui_internal.h"
#include "ImGui/imgui_impl_metal.h"
#include "ImGui/CustomWidgets.h"
#include "Includes/Fonts/Fonts.hpp"
#include "Mods.h"

using namespace std;

void LoadMenu();
void SetStyles();
extern ImVec2 MenuOrigin;
extern ImVec2 MenuSize;
extern bool MoveMenu;
extern bool StreamerMode;
extern UITextField* hideRecordTextfield;
extern void LoadMods();

#endif
