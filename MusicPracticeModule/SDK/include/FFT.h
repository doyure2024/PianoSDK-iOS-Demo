//
// Created by kingcyk on 2/9/21.
//

#ifndef ENJOYMUSICPIANO_FFT_H
#define ENJOYMUSICPIANO_FFT_H

#ifdef ENJOYMUSICPIANO_PLATFORM_ANDROID
#include "FFTW.h"
#endif

#ifdef ENJOYMUSICPIANO_PLATFORM_IOS

#include "FFTA.h"

#endif

#include <complex>
#include <vector>

namespace enjoymusic {
    namespace onset {
        class FFT {
        public:
            FFT();

            std::vector<std::complex<float> > compute(std::vector<float> &signal);

            void configure();

        private:
#ifdef ENJOYMUSICPIANO_PLATFORM_ANDROID
            FFTW *_fft;
#endif

#ifdef ENJOYMUSICPIANO_PLATFORM_IOS
            FFTA *_fft;
#endif
        };
    }
}

#endif //ENJOYMUSICPIANO_FFT_H
