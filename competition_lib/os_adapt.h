#ifdef _WIN32
#define PLAY_SOUND(F)   PlaySound(F, NULL, SND_FILENAME | SND_SYNC |SND_NOSTOP |SND_NOWAIT )
#define SLEEP(x)    Sleep(x)
#endif

#ifdef __linux__
#define PLAY_SOUND(F) PlaySound(F)
#define SLEEP(x)    sleep(x)
#endif

