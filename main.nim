import posix, os, strutils
import "audio_frontend", "data", "utils", "lyric_backend"



#zstandardCompressDir(DATA_DIR)

var ctx*: AudioContext = initAudioState("data/mili.flac")
var lyric_data = parseLyricFile(readFile("data/lyrics.lrc"))

startPlayback(ctx); toggleSound(ctx.sound, Start)

echo CLEAR
while true:
    let audio_ms = pollElapsedMillisecs(ctx.sound, ctx.runtime.sampleRate)
    discard getCurrentLyric(lyric_data, audio_ms)
    sleep(950)