import "miniaudio/miniaudio", "utils"

export MaEngine, MaDecoder, MaSound
export ma_result, ma_bool8, ma_bool32
export ma_uint8, ma_uint16, ma_uint32, ma_uint64
export ma_int8, ma_int16, ma_int32, ma_int64
export ma_sound_init_from_file, ma_sound_init_from_data_source


type AudioDataKind* = enum
    bufstr, bufseq

type AudioRuntime* = object
    case kind*: AudioDataKind
    of bufstr:
        bufferStr*: string
    of bufseq:
        bufferSeq*: seq[byte]
    elapsedFrames*: uint64
    sampleRate*: uint32
    volume*: float
    isPlaying*: bool

type AudioContext* = object # Core object
    engine*: ptr MaEngine
    decoder*: ptr MaDecoder
    sound*: ptr MaSound
    runtime*: AudioRuntime

type SoundState* = enum
    Start, Stop


proc setupEngine*(): ptr MaEngine =
    echo("Setting up engine...")
    result = passPtr(MaEngine, alloc0(ma_engine_size()))
    
    if result.isNil:
        quit("Engine memory error: Out of memory", 1)
    if ma_engine_init(nil, result) != MA_SUCCESS:
        quit("Engine setup failed: !MA_SUCCESS", 1)


proc setupDecoder*(): ptr MaDecoder = 
    echo("Setting up decoder...")
    result = passPtr(MaDecoder, alloc0(ma_decoder_size()))

    if result.isNil:
        quit("Decoder memory error: Out of memory", 1)
    if ma_decoder_init_memory(nil, 0, nil, result) != MA_SUCCESS: 
        quit("Decoder setup failed: !MA_SUCCESS")


proc setupSound*(): ptr MaSound =
    echo("Setting up sound...")
    result = passPtr(MaSound, alloc0(ma_sound_size()))

    if result.isNil:
        quit("Sound memory error: Out of memory", 1)



proc shutdownEngine*(engine: ptr MaEngine) =
    echo("Shutting down engine...")

    ma_engine_uninit(engine)
    dealloc(engine)

proc shutdownDecoder*(decoder: ptr MaDecoder) =
    echo("Shutting down decoder...")

    if ma_decoder_uninit(decoder) != MA_SUCCESS:
        quit("Decoder shutdown failed: !MA_SUCCESS")
    dealloc(decoder)

proc shutdownSound*(sound: ptr MaSound) =
    echo("Shutting down sound...")

    ma_sound_uninit(sound)
    dealloc(sound)


proc toggleSound*(sound: ptr MaSound, state: SoundState) =
    case state
    of Start:
        if not maBoolToBool(ma_sound_is_playing(sound)):
            if ma_sound_start(sound) != MA_SUCCESS:
                quit("Sound start failed: !MA_SUCCESS")
    of Stop:
        if maBoolToBool(ma_sound_is_playing(sound)):
            if ma_sound_stop(sound) != MA_SUCCESS:
                quit("Sound stop failed: !MA_SUCCESS")


func pollElapsedFrames*(sound: ptr MaSound): uint64 =
    result = ma_sound_get_time_in_pcm_frames(sound)

proc getSampleRate*(engine: ptr MaEngine): uint32 =
    result = ma_engine_get_sample_rate(engine)
    if result == 0:
        quit("Sample rate returned illegal value: " & $result, 1)

func getVolume*(sound: ptr MaSound): float =
    result = ma_sound_get_volume(sound)


