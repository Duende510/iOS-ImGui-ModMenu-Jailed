#ifndef MODS_H
#define MODS_H

#include "Includes/Unity/Vector3.h"
#include "Includes/Unity/Unity.h"
#include "Includes/Unity/Quaternion.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "dlfcn.h"
#include <vector>
#include <functional>
#include <string>
#include "ImGui/imgui.h"
#include "Includes/Hooking/JailedHook.h"

struct Mods {
    bool bool1 = false, bool2 = false, bool3 = false;
    std::string myText = "Initial Text";
    std::string inputText = "";
    float floatVal = 0;
    int intval = 0, intval2 = 0;
};

extern Mods mods;
void LoadMods();

#endif // MODS_H
