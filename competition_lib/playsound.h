#include "WaveFile.h"
#include <alsa/asoundlib.h>
#include <string>


using namespace std;

class PlaySound
{

    static const char * device;            /* playback device */
    int err;
    unsigned int i;
    static snd_pcm_t *handle;
    snd_pcm_sframes_t frames;
    bool play(WaveFile & waveFile);
public:
    static bool openPcm();
    static void closePcm();
    PlaySound();
    bool playFile(string fileName);
    void printWAVInfo(WaveFile & wavFile);
};