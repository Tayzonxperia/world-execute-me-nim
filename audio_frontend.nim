import posix, os, strutils
import "audio_backend", "utils"

export AudioContext, AudioRuntime, AudioDataKind, SoundState, toggleSound
export getSampleRate

proc initAudioState*[T](source: T): AudioContext =
    echo("Bringing the miniaudio interface online")
    
    result.engine = setupEngine()

    when T is string:
        result.runtime.kind = bufstr
        result.runtime.bufferStr = source
    elif T is seq[byte]:
        result.runtime.kind = bufseq
        result.runtime.bufferSeq = source
        result.decoder = setupDecoder()
    else:
        quit("Only data types supported are string and seq[byte], provided type was: " & $typeof(T), 1)

    result.sound = setupSound()

    result.runtime.sampleRate = getSampleRate(result.engine)
    result.runtime.volume = getVolume(result.sound)

    echo("Miniaudio interface online!")
    return result


proc deinitAudioState*(state: AudioContext) =
    echo("Bringing the miniaudio interface offline")

    if state.runtime.isPlaying:
        echo("Stopping playback")
        toggleSound(state.sound, Stop)

    shutdownSound(state.sound)
    if state.runtime.kind == bufseq: shutdownDecoder(state.decoder)
    shutdownEngine(state.engine)

    echo("Miniaudio interface offline!")


proc startPlayback*(context: AudioContext) =
    echo("Loading...\n")

    if not context.runtime.bufferStr.cstring.isNil:
        echo("Starting playback:\nData source: " & $context.runtime.kind & " (" & context.runtime.bufferStr & ")")
        var buffer = cstring(context.runtime.bufferStr)
        if ma_sound_init_from_file(context.engine, buffer, 0, nil, nil, context.sound) != MA_SUCCESS:
            quit("Source setup failed: !MA_SUCCESS", 1)
    else:
        echo("Starting playback:\nData source: " & $context.runtime.kind)
        var buffer = addr context.runtime.bufferSeq[0]
        if ma_sound_init_from_data_source(context.engine, buffer, 0, nil, context.sound) != MA_SUCCESS:
            quit("Source setup failed: !MA_SUCCESS", 1)


func pollElapsedSecs*(sound: ptr MaSound, sampleRate: uint32): float64 =
    let frames = pollElapsedFrames(sound)
    let secs = framesToSecs(frames, sampleRate)
    result = secs

func pollElapsedMillisecs*(sound: ptr MaSound, sampleRate: uint32): float64 =
    let frames = pollElapsedFrames(sound)
    let secs = framesToSecs(frames, sampleRate)
    result = secs * 1000
    