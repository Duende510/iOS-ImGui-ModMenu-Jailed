#include <mach-o/dyld.h>
#include "Vector3.h"
#include <map>
#include <substrate.h>
#include <codecvt>
#import "UIKit/UIKit.h"
#import <vector>
#import <initializer_list>
#import <string>
#ifndef UNITY_H
#define UNITY_H

template <typename T>
struct monoArray
{

    void *klass;
    void *monitor;
    void *bounds;
    int max_length;
    void *vector[1];
    int getLength()
    {
        return max_length;
    }
    T getPointer()
    {
        return (T)vector;
    }
    T operator[](int i)
    {
        return getPointer()[i];
    }

    const T operator[](int i) const
    {
        return getPointer()[i];
    }

    bool Contains(T item)
    {
        for (int i = 0; i < max_length; i++)
        {
            if (getPointer()[i] == item)
                return true;
        }
        return false;
    }
};

typedef struct _monoString
{
    void *klass;
    void *monitor;
    int length;
    wchar_t chars[1];
    int getLength()
    {
        return length;
    }
    const char *getChars()
    {
        NSString *str = [[NSString alloc] initWithBytes:chars
                                                 length:length * sizeof(wchar_t)
                                               encoding:NSUTF16LittleEndianStringEncoding];
        return [str UTF8String];
    }
    NSString *toNSString()
    {
        return [[NSString alloc] initWithBytes:chars
                                        length:length * sizeof(wchar_t)
                                      encoding:NSUTF16LittleEndianStringEncoding];
    }

    char *toCString()
    {
        NSString *str = toNSString();
        return (char *)[str UTF8String];
    }
    std::string toCPPString()
    {
        return std::string(toCString());
    }
} monoString;

/*
monoString *CreateMonoString(const char *str) {
    monoString *(*String_CreateString)(void *instance, const char *str) = (monoString *(*)(void *, const char *))getRealOffset(0x10257A5B8);

    return String_CreateString(NULL, str);
}*/

template <typename T>
struct monoList
{
    void *unk0;
    void *unk1;
    monoArray<T> *items;
    int size;
    int version;

    T getItems()
    {
        return items->getPointer();
    }

    int getSize()
    {
        return size;
    }

    int getVersion()
    {
        return version;
    }
};

/*
This struct represents a Dictionary. In the dump, a Dictionary is defined as Dictionary`1.

You could think of this as a Map in Java or C++. Keys correspond with values. This wraps the C arrays for keys and values.

If you had this in a dump,

public class GameManager {
    public Dictionary`1<int, Player> players; // 0xB0
    public Dictionary`1<Weapon, Player> playerWeapons; // 0xB8
    public Dictionary`1<Player, string> playerNames; // 0xBC
}

to get players, it would look like this: monoDictionary<int *, void **> *players = *(monoDictionary<int *, void **> **)((uint64_t)player + 0xb0);
to get playerWeapons, it would look like this: monoDictionary<void **, void **> *playerWeapons = *(monoDictionary<void **, void **> **)((uint64_t)player + 0xb8);
to get playerNames, it would look like this: monoDictionary<void **, monoString **> *playerNames = *(monoDictionary<void **, monoString **> **)((uint64_t)player + 0xbc);

To get the C array of keys, call getKeys.
To get the C array of values, call getValues.
To get the number of keys, call getNumKeys.
To get the number of values, call getNumValues.
*/
template <typename K, typename V>
struct monoDictionary
{
    void *unk0;
    void *unk1;
    monoArray<int **> *table;
    monoArray<void **> *linkSlots;
    monoArray<K> *keys;
    monoArray<V> *values;
    int touchedSlots;
    int emptySlot;
    int size;

    K getKeys()
    {
        return keys->getPointer();
    }

    V getValues()
    {
        return values->getPointer();
    }

    int getNumKeys()
    {
        return keys->getLength();
    }

    int getNumValues()
    {
        return values->getLength();
    }

    int getSize()
    {
        return size;
    }
};

template <typename TKey, typename TValue>
struct monoDictionary2
{
    struct Entry
    {
        int hashCode, next;
        TKey key;
        TValue value;
    };
    void *klass;
    void *monitor;
    monoArray<int> *buckets;
    monoArray<Entry> *entries;
    int count;
    int version;
    int freeList;
    int freeCount;
    void *comparer;
    monoArray<TKey> *keys;
    monoArray<TValue> *values;
    void *syncRoot;

    std::map<TKey, TValue> toMap()
    {
        std::map<TKey, TValue> ret;
        auto lst = entries->template toCPPlist();
        for (auto enter : lst)
            ret.insert(std::make_pair(enter.key, enter.value));
        return std::move(ret);
    }

    std::vector<TKey> getKeys()
    {
        std::vector<TKey> ret;
        auto lst = entries->template toCPPlist();
        for (auto enter : lst)
            ret.push_back(enter.key);
        return std::move(ret);
    }

    std::vector<TValue> getValues()
    {
        std::vector<TValue> ret;
        auto lst = entries->template toCPPlist();
        for (auto enter : lst)
            ret.push_back(enter.value);
        return std::move(ret);
    }

    int getSize()
    {
        return count;
    }

    int getVersion()
    {
        return version;
    }

    bool TryGet(TKey key, TValue &value);
    void Add(TKey key, TValue value);
    void Insert(TKey key, TValue value);
    bool Remove(TKey key);
    bool ContainsKey(TKey key);
    bool ContainsValue(TValue value);

    TValue Get(TKey key)
    {
        TValue ret;
        if (TryGet(key, ret))
            return ret;
        return {};
    }

    TValue operator[](TKey key)
    {
        return Get(key);
    }
};

inline int GetObscuredIntValue(uint64_t location)
{
    int cryptoKey = *(int *)location;
    int obfuscatedValue = *(int *)(location + 0x4);
    return obfuscatedValue ^ cryptoKey;
}

inline bool GetObscuredBoolValue(uint64_t location)
{
    int cryptoKey = *(int *)location;
    int obfuscatedValue = *(int *)(location + 0x4);
    return (bool)obfuscatedValue ^ cryptoKey;
}

inline void SetObscuredIntValue(uint64_t location, int value)
{
    int cryptoKey = *(int *)location;
    *(int *)(location + 0x4) = value ^ cryptoKey;
}

inline void SetObscuredBoolValue(uint64_t location, bool value)
{
    int cryptoKey = *(int *)location;
    *(int *)(location + 0x4) = value ^ cryptoKey;
}

inline float GetObscuredFloatValue(uint64_t location)
{
    int cryptoKey = *(int *)location;
    int obfuscatedValue = *(int *)(location + 0x4);

    union intfloat
    {
        int i;
        float f;
    };

    /* use this intfloat to set the integer representation of our parameter value, which will also set the float value */
    intfloat IF;
    IF.i = obfuscatedValue ^ cryptoKey;

    return IF.f;
}

inline void SetObscuredFloatValue(uint64_t location, float value)
{
    int cryptoKey = *(int *)location;

    union intfloat
    {
        int i;
        float f;
    };

    /* use this intfloat to get the integer representation of our parameter value */
    intfloat IF;
    IF.f = value;

    /* use this intfloat to generate our hacked ObscuredFloat */
    intfloat IF2;
    IF2.i = IF.i ^ cryptoKey;

    *(float *)(location + 0x4) = IF2.f;
}
#endif UNITY_H
