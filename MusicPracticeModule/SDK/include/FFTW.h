//
// Created by kingcyk on 2/8/21.
//

#ifndef ENJOYMUSICPIANO_FFTW_H
#define ENJOYMUSICPIANO_FFTW_H

#include "EnjoyMusicException.h"
#include <complex>
#include <vector>
#include "fftw3.h"

namespace enjoymusic {
    namespace onset {
        class FFTW {
        public:
            FFTW();

            ~FFTW();

            std::vector<std::complex<float> > compute(std::vector<float> &signal);

            void configure();

        protected:
            fftwf_plan _fftPlan{};
            int _fftPlanSize{};
            float *_input{};
            std::complex<float> *_output{};

            void createFFTObject(int size);
        };
    }
}

#endif //ENJOYMUSICPIANO_FFTW_H
