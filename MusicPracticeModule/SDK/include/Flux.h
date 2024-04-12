//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_FLUX_H
#define ENJOYMUSICPIANO_FLUX_H

#include "EnjoyMusicException.h"
#include <vector>

namespace enjoymusic {
    namespace onset {
        class Flux {
        public:
            Flux();

            void configure();

            float compute(std::vector<float> &spectrum);

            void reset() {
                _spectrumMemory.clear();
            }

        private:
            std::vector<float> _spectrumMemory;
        };
    }
}

#endif //ENJOYMUSICPIANO_FLUX_H
