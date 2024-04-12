#ifndef ENJOYMUSICPIANO_ENJOYMUSICLOGGER_H
#define ENJOYMUSICPIANO_ENJOYMUSICLOGGER_H

#ifdef ENJOYMUSICPIANO_PLATFORM_ANDROID
#include <android/log.h>

#define log_print __android_log_print
#define LOG_TAG "Piano SDK"
#define LOGI(...) log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGD(...) log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGW(...) log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#endif

#ifdef ENJOYMUSICPIANO_PLATFORM_IOS

#include <iostream>
#include <cstring>

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

void Log_Recursive(const char *file, int line, std::ostringstream &msg) {
    std::cout << file << "(" << line << "): " << msg.str() << std::endl;
}

template<typename T, typename... Args>
void Log_Recursive(const char *file, int line, std::ostringstream &msg,
                   T value, const Args &... args) {
    msg << value;
    Log_Recursive(file, line, msg, args...);
}

template<typename... Args>
void LogWrapper(const char *file, int line, const Args &... args) {
    std::ostringstream msg;
    Log_Recursive(file, line, msg, args...);
}

#define LOGI(...) LogWrapper(__FILENAME__, __LINE__, "[INFO] ", __VA_ARGS__)
#define LOGD(...) LogWrapper(__FILENAME__, __LINE__, "[DEBUG] ", __VA_ARGS__)
#define LOGE(...) LogWrapper(__FILENAME__, __LINE__, "[ERROR] ", __VA_ARGS__)
#define LOGW(...) LogWrapper(__FILENAME__, __LINE__, "[WARNING] ", __VA_ARGS__)

#endif

#endif //ENJOYMUSICPIANO_PIANO_H