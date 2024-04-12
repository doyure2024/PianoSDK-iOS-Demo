//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_FFTA_H
#define ENJOYMUSICPIANO_FFTA_H

#include "EnjoyMusicException.h"
#include <complex>
#include <vector>
#include <Accelerate/Accelerate.h>

namespace enjoymusic {
    namespace onset {
        class FFTA {
        public:
            FFTA() {
                fftSetup = NULL;
                accelBuffer.realp = NULL;
                accelBuffer.imagp = NULL;
            }

            ~FFTA();

            std::vector<std::complex<float> > compute(std::vector<float> &signal);

            void configure();

        protected:
            FFTSetup fftSetup;
            int logSize;
            int _fftPlanSize;
            DSPSplitComplex accelBuffer;

            void createFFTObject(int size);
        };
    }
}

#endif //ENJOYMUSICPIANO_FFTA_H
