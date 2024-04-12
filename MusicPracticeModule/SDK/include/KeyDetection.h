/*
 * @Author: your name
 * @Date: 2021-04-29 13:38:44
 * @LastEditTime: 2021-06-11 15:34:35
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /piano-sdk/KeyDetection.h
 */
//
// Created by kingcyk on 1/25/21.
//

#ifndef ENJOYMUSICPIANO_KEYDETECTION_H
#define ENJOYMUSICPIANO_KEYDETECTION_H

#include "EnjoyMusicException.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/interpreter.h"
#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/tools/gen_op_registration.h"
#include "ScoreReader.h"
#include <vector>
#include <deque>
#include <iostream>

namespace enjoymusic {
    namespace key {
        class KeyDetection {
        public:
            KeyDetection() {
                _prepared = false;
            }

            ~KeyDetection();

            int loadModel(char *path, bool isOldModel);

//            int loadModel2(char *path);
            int prepare();

            void setThread(int threads);

            std::vector<int> compute(std::vector<float> &buffer, int length);

            std::vector<int> compute(std::vector<float> &buffer, int length, float zscoreThreshold);

            std::vector<int> compute(std::vector<float> &melBuffer);

            std::vector<int> compute(std::vector<float> &melBuffer, float threshold, bool filter = true);

            std::vector<std::vector<int>> compute2s(std::vector<float> &melBuffer);

            std::vector<int> getCurrentResult();

            void setScore(std::vector<score::NoteSeries> scores);

            std::vector<std::vector<float>> all_output_tensors;
            std::vector<std::vector<std::vector<int>>> all_output_frames;

            // Classifier
            int loadClsModel(char *path);

            int clsPrepare();

            std::vector<float> clsCompute(std::vector<float> &melBuffer);

            bool hasBlankFrame;

        private:
            bool _prepared;
            int _threads = 2;
            bool _isOldModel = false;
            std::unique_ptr<tflite::FlatBufferModel> _model;
            tflite::ops::builtin::BuiltinOpResolver _resolver;
            std::unique_ptr<tflite::Interpreter> _interpreter;
            // Classifier
            std::unique_ptr<tflite::FlatBufferModel> _clsModel;
            tflite::ops::builtin::BuiltinOpResolver _clsResolver;
            std::unique_ptr<tflite::Interpreter> _clsInterpreter;

//            std::unique_ptr<tflite::FlatBufferModel> _model2;
//            tflite::ops::builtin::BuiltinOpResolver _resolver2;
//            std::unique_ptr<tflite::Interpreter> _interpreter2;
            std::vector<int> _last_frame_result;
            std::set<int> lastFrameResultSet;
            std::vector<int> lastResult;
            std::multimap<int, int> lastResultMap;
            int lastBlankFrameIndex = 0;
        };
    }
}

#endif //ENJOYMUSICPIANO_KEYDETECTION_H
