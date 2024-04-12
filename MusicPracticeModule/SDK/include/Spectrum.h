//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_SPECTRUM_H
#define ENJOYMUSICPIANO_SPECTRUM_H

#include <complex>
#include <vector>
#include "FFT.h"
#include "Magnitude.h"
#include <iostream>

namespace enjoymusic {
    namespace onset {
        class Spectrum {
        protected:
            FFT _fft;
            Magnitude _magnitude;
        public:
            Spectrum() {
                _fft = FFT();
                _magnitude = Magnitude();
            }

            ~Spectrum();

            void configure();

            std::vector<float> compute(std::vector<float> &signal);
        };
    }
}

#endif //ENJOYMUSICPIANO_SPECTRUM_H
