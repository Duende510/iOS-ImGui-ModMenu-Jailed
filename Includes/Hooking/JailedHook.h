#include "../Libs/dobby_defines.h"
#include "../SCLAlertView/SCLAlertView.h"
#include <libgen.h>
#include <mach-o/fat.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <mach/vm_page_size.h>
#include <Foundation/Foundation.h>
#include <map>
#include <deque>
#include <vector>
#include <array>
#include <substrate.h>


#define DEBUG

#ifdef DEBUG
#define log(...) NSLog(__VA_ARGS__)
#else
#define log(...)
#endif

#ifdef __cplusplus
extern "C" {
#endif

NSString* StaticInlineHookPatch(char* machoPath, uint64_t vaddr, char* patch);
void* StaticInlineHookFunction(char* machoPath, uint64_t vaddr, void* replacement);
void* find_module_by_path(char* machoPath);
BOOL DeactiveCodePatch(char* machoPath, uint64_t vaddr, char* patch);
BOOL ActiveCodePatch(char* machoPath, uint64_t vaddr, char* patch);
extern char* BinaryName; 

#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]


#define HOOK(x, y, z) \
NSString* result_##y = StaticInlineHookPatch(BinaryName, x, nullptr); \
if (result_##y) { \
    log(@"Hook result: %s", result_##y.UTF8String); \
    void* result = StaticInlineHookFunction(BinaryName, x, (void *) y); \
    log(@"Hook result %p", result); \
    *(void **) (&z) = (void*) result; \
}

#define HOOKPTR(x, z) \
NSString* result_##z = StaticInlineHookPatch(BinaryName, x, nullptr); \
if (result_##z) { \
    log(@"Hook result: %s", result_##z.UTF8String); \
    void* result = StaticInlineHookFunction(BinaryName, x, nullptr); \
    log(@"Retrieved function pointer %p", result); \
    *(void **) (&z) = (void*) result; \
}

#define PATCHOFFSET(x, z) \
NSString* result_patch = StaticInlineHookPatch(BinaryName, x, z); \
if (result_patch) { \
    log(@"Hook result: %s", [result_patch UTF8String]); \
    BOOL success = ActiveCodePatch(BinaryName, x, z); \
    log(@"Patch result: %d", success); \
}

#ifdef __cplusplus
}
#endif
