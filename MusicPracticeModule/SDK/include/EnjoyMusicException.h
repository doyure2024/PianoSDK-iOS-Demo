//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_ENJOYMUSICEXCEPTION_H
#define ENJOYMUSICPIANO_ENJOYMUSICEXCEPTION_H


#include <exception>
#include <string>
#include <sstream>

namespace enjoymusic {
    class EnjoyMusicException : public std::exception {
    public:
        EnjoyMusicException(const char *msg) : std::exception(), _msg(msg) {}

        EnjoyMusicException(const std::string &msg) : std::exception(), _msg(msg) {}

        EnjoyMusicException(const std::ostringstream &msg) : std::exception(), _msg(msg.str()) {}

        template<typename T, typename U>
        EnjoyMusicException(const T &a, const U &b) : std::exception() {
            std::ostringstream oss;
            oss << a << b;
            _msg = oss.str();
        }

        template<typename T, typename U, typename V>
        EnjoyMusicException(const T &a, const U &b, const V &c) : exception() {
            std::ostringstream oss;
            oss << a << b << c;
            _msg = oss.str();
        }

        template<typename T, typename U, typename V, typename W>
        EnjoyMusicException(const T &a, const U &b, const V &c, const W &d) : exception() {
            std::ostringstream oss;
            oss << a << b << c << d;
            _msg = oss.str();
        }

        virtual ~EnjoyMusicException() throw() {}

        virtual const char *what() const throw() { return _msg.c_str(); }

    protected:
        std::string _msg;
    };
}

#endif //ENJOYMUSICPIANO_ENJOYMUSICEXCEPTION_H
