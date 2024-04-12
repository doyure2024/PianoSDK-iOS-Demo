//
// Created by kingcyk on 2/2/21.
//

#ifndef ENJOYMUSICPIANO_SCOREREADER_H
#define ENJOYMUSICPIANO_SCOREREADER_H

#include "EnjoyMusicException.h"
#include "jsoncpp/json/json.h"

namespace enjoymusic {
    namespace score {
        struct Note {
            int time;
            int duration;
            int key;
            int index;
        };

        struct NoteSeries {
            std::vector<Note> notes;
        };

        struct Score {
            int tempo;
            std::vector<NoteSeries> noteSeries;
        };

        class ScoreReader {
        public:
            ScoreReader();

            ~ScoreReader();

            void loadScore(std::string &document);

            Score _score;
        private:
        };

    }
}

#endif //ENJOYMUSICPIANO_SCOREREADER_H
