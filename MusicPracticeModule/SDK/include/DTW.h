//
// Created by wzl on 2/8/21.
//
#ifndef ENJOYMUSICPIANO_DTW_H
#define ENJOYMUSICPIANO_DTW_H

#include "ScoreReader.h"
#include <ctime>
#include <list>
#include <tuple>

namespace enjoymusic {
    namespace dtw {
        class DTW {
        public:
            DTW();

            ~DTW();

            void init(std::vector<std::vector<score::Note> > &array);

            std::vector<std::vector<score::Note> > allTargetArray;
            std::vector<std::vector<int> > allInputArray = {};
            std::vector<std::vector<uint32_t> > costMatrix = {};
            int currentMetIndex = 0;
            std::vector<int> pathArray;
            bool alreadyMatchedFirst = false;
            time_t startDate = time(NULL);
            time_t endDate = time(NULL);
            bool alreadyEnd = false;
            int numberOfLeaps = 0;
            int numberOfWrongNotes = 0;
            time_t noteStartDate = time(NULL);
            time_t noteEndDate = time(NULL);

            std::vector<float> noteRhythmFactors;

            float speedScore = 0.0;
            float intonationScore = 0.0;
            float integrityScore = 0.0;
            float rhythmScore = 0.0;
            float smoothnessScore = 0.0;
            float overallScore = 0.0;

            std::vector<int> wrongNodeIndices;
            std::vector<std::vector<int> > messRange;
            std::vector<std::vector<int> > forwardMessRange;

            void updateCostMatrix(std::vector<int> &inputArray, bool hasBlankFrame);

            void updateCostMatrix(std::vector<int> &inputArray, std::vector<int> &secondArray,
                                  bool hasBlankFrame);

            int
            getLoss(std::vector<score::Note> &targetArray, std::vector<int> &inputArray, int index);

            bool
            considerCorrect(std::vector<score::Note> &targetArray, std::vector<int> &inputArray);
int

            calculateMatchingScore(std::vector<score::Note> &targetArray, std::vector<int> &inputArray,
                            std::vector<int> &secondArray, bool hasBlankFrame);

            bool checkResult(std::vector<int> &target0, std::vector<int> &result0);

            int calculateContainingCondition(std::vector<int> &target0, std::vector<int> &result0);

            std::vector<float> getScore();

            std::string getReport();

            std::vector<int> getCurrentTarget();

            void setMode(int mode);

        private:
            int lastMetIndex = -1;

            static float calculateSD(std::vector<float> &data);

            int _currentMode = 1;

        };
    } // namespace dtw
} // namespace enjoymusic

#endif //ENJOYMUSICPIANO_DTW_H
