/* The MIT License (MIT)

Copyright (c) 2015 Johannes Häggqvist

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/
#include "WaveFile.h"
#include <iostream>
#include <string>
#include <fstream>
#include "playsound.h"


using namespace std;
snd_pcm_t * PlaySound::handle = NULL;
const char * PlaySound::device = "default";            /* playback device */
 
 

PlaySound::PlaySound()
{

}
bool PlaySound::openPcm()
{
	if(handle == NULL)
	{
    	int err = 0;
		if ((err = snd_pcm_open(&handle, device, SND_PCM_STREAM_PLAYBACK, 0)) < 0) {
			printf("Playback open error: %s\n", snd_strerror(err));
			return false;
		}
	}
	return true;
}

void PlaySound::closePcm()
{
	if(handle == NULL)
		return;
	snd_pcm_drop(handle);
	snd_pcm_close(handle);
	handle = NULL;
}

bool PlaySound::play(WaveFile & waveFile)
{
	const char * buffer = waveFile.GetData();
    int err;
    unsigned int i;
    snd_pcm_sframes_t frames;
	snd_pcm_format_t snd_format = SND_PCM_FORMAT_S8;
	switch(waveFile.GetBitsPerSample())
	{
	case 8:
		snd_format = SND_PCM_FORMAT_U8;
		break;
	case 16:
		snd_format = SND_PCM_FORMAT_S16_LE;
		break;
	case 24:
		break;
	case 32:
		snd_format = SND_PCM_FORMAT_S32_LE;
		break;
	default:
		break;
	}
	if ((err = snd_pcm_set_params(handle,
                      snd_format,
                      SND_PCM_ACCESS_RW_INTERLEAVED,
                      waveFile.GetNumChannels(),
                      waveFile.GetSampleRate(),
                      1,
                      500000)) < 0) {   /* 0.5sec */
        printf("Playback open error: %s\n", snd_strerror(err));
		return false;
    }

	int frameSize = waveFile.GetBitsPerSample() * waveFile.GetNumChannels() / 8;
	int totalFrames = waveFile.GetDataSize() / frameSize;
	int wroteFrames = 0;
	while(wroteFrames < totalFrames)
	{
		int ret = snd_pcm_writei(handle, buffer + wroteFrames * frameSize, totalFrames - wroteFrames);
		if (ret < 0)
		{
			printf("snd_pcm_writei failed: %s\n", snd_strerror(ret));
			ret = snd_pcm_recover(handle, frames, 0);

			snd_pcm_close(handle);
			return false;
		}
		wroteFrames += ret;
		err = snd_pcm_drain(handle);
		if (err < 0)
			printf("snd_pcm_drain failed: %s\n", snd_strerror(err));
	}
	snd_pcm_drop(handle);
    return true;
}
void PlaySound::printWAVInfo(WaveFile & wavFile)
{
	if (wavFile.IsLoaded())
	{
		std::cout <<
			"Meta data:\n"
			" - Audio format : " << wavFile.GetAudioFormatString() << "\n"
			" - Channels     : " << wavFile.GetNumChannels() << "\n"
			" - Sample rate  : " << wavFile.GetSampleRate() << "\n"
			" - Sample size  : " << wavFile.GetBitsPerSample() << " bits" << std::endl;
	}
}
bool PlaySound::playFile(const string fileName)
{
	WaveFile wavFile(fileName);
	return play(wavFile);
}