#include "WaveFile.h"
#include "asoundlib.h"
#include <string>


using namespace std;

class PlaySound
{

    const char * device = "default";            /* playback device */
    int err;
    unsigned int i;
    snd_pcm_t *handle;
    snd_pcm_sframes_t frames;
    bool play(WaveFile & waveFile);
public:
    PlaySound();
    int playFile(string fileName);
    void printWAVInfo(WaveFile & wavFile);
};