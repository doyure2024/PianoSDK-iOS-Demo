//
// Created by kingcyk on 1/25/21.
//

#ifndef ENJOYMUSICPIANO_PIANO_H
#define ENJOYMUSICPIANO_PIANO_H

#include "OnsetDetection.h"
#include "KeyDetection.h"
#include "ScoreReader.h"
#include "DTW.h"
#include "Timer.h"
#include <vector>
#include <deque>
#include <numeric>
#include <algorithm>
#include <chrono>
#include <deque>

namespace enjoymusic {
    namespace piano {
        // API Class
        class Piano {
        public:
            Piano();

            ~Piano();

            int loadLicense(std::string &license);

            int prepare();

            int loadModel(char *path, bool isOldModel = false);

            int loadClsModel(char *path);

            int loadScore(std::string &document);

            /*
             * mode: 0: 识别, 1: 跟弹, 2: 自由
             */
            void setMode(int mode);

            std::vector<int> compute(std::vector<float> &buffer);

            std::vector<std::vector<int>> compute2s(std::vector<float> &buffer);

            bool shouldGoNext(std::vector<float> &buffer, int length);

            bool skipNext();

            int noteIndexToGo(std::vector<float> &buffer, int length);

            std::vector<int> keysAtHostTime(std::vector<float> &buffer, int length, int hostTime);

            float getScoreAtHostTime(int keys, int hostTime);

            std::vector<float> getScore();

            std::string getReport();

            std::vector<int> getCurrentTarget();

            std::vector<int> getCurrentResult();

            void setThread(int threads);

            void setLowThreshold(float thres);

            void setCheckPercent(float percent);

            void release();

        private:
            class Piano_Impl;

            Piano_Impl *pimpl;

        };
    }
}

#endif //ENJOYMUSICPIANO_PIANO_H
