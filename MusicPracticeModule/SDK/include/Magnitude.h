//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_MAGNITUDE_H
#define ENJOYMUSICPIANO_MAGNITUDE_H

#include <vector>
#include <iostream>
#include <complex>

namespace enjoymusic {
    namespace onset {
        class Magnitude {
        public:
            Magnitude();

            std::vector<float> compute(std::vector<std::complex<float> > &input);
        };
    }
}

#endif //ENJOYMUSICPIANO_MAGNITUDE_H
