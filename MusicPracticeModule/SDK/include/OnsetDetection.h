//
// Created by kingcyk on 1/22/21.
//

#ifndef ENJOYMUSICPIANO_ONSETDETECTION_H
#define ENJOYMUSICPIANO_ONSETDETECTION_H

#include "Flux.h"
#include "Spectrum.h"
#include "EnjoyMusicException.h"
#include <vector>
#include <deque>
#include <numeric>
#include <iostream>

namespace enjoymusic {
    namespace onset {
        class OnsetDetection {
        private:
            float _onsetDetection;
            Spectrum *_spectrum;
            Flux *_flux;

            int _buffer_count;
            int _n_prev_values;
            std::deque<float> _prev_values;
//            std::deque<float> _prev_values_copy;  // needed to compute median as input array is modified
            float _threshold;
            float _mean_weight;
            float _median_weight;
            int _median_window;
            float _largest_peak;
            float _noise_ratio;
            float _max_threshold;

            float _median(std::deque<float> &input);

            float _mean(std::deque<float> &input);

        public:
            OnsetDetection() {
                _flux = new Flux();
                _spectrum = new Spectrum();
                _buffer_count = 0;

                _prev_values = std::deque<float>(10, 0.0);
//                _prev_values_copy = std::deque<float>(10, 0.0);

                _n_prev_values = 10;

                _threshold = 0.1f;
                _mean_weight = 2.f;
                _median_weight = 1.f;
                _median_window = 7;
                _largest_peak = 0.f;
                _noise_ratio = 0.05f;
                _max_threshold = 0.05f;
                max_odf_value = 0.f;
            }

            ~OnsetDetection();

            void reset();

            void configure();

            std::vector<float> getSpectrum(std::vector<float> &signal);

            float computeFromSpectrum(std::vector<float> &spectrum);

            float compute(std::vector<float> &signal);

            bool isOnset(float odf_value);

            float max_odf_value;
        };
    }
}

#endif //ENJOYMUSICPIANO_ONSETDETECTION_H
