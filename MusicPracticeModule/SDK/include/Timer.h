//
// Created by kingcyk on 2/19/21.
//

#include <functional>
#include <chrono>
#include <future>

class later {
public:
    template<class callable, class... arguments>
    later(int after, bool async, callable &&f, arguments &&... args) {
        std::function<typename std::result_of<callable(arguments...)>::type()> task(
                std::bind(std::forward<callable>(f), std::forward<arguments>(args)...));
        if (async) {
            std::thread([after, task]() {
                std::this_thread::sleep_for(std::chrono::milliseconds(after));
                task();
            }).detach();
        } else {
            std::this_thread::sleep_for(std::chrono::milliseconds(after));
            task();
        }
    }
};