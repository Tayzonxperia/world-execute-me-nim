{.compile: "miniaudio.c", passC: "-DMA_USE_STDINT".}

#[ Miniaudio Nim bindings
   ---------------------- ]#

type
  ma_int8*   = int8
  ma_uint8*  = uint8
  ma_int16*  = int16
  ma_uint16* = uint16
  ma_int32*  = int32
  ma_uint32* = uint32
  ma_int64*  = int64
  ma_uint64* = uint64
  ma_bool8* = uint8
  ma_bool32* = uint32


type
  ma_result* = enum
    MA_FAILED_TO_STOP_BACKEND_DEVICE = -303,
    MA_FAILED_TO_START_BACKEND_DEVICE = -302,
    MA_FAILED_TO_OPEN_BACKEND_DEVICE = -301, MA_FAILED_TO_INIT_BACKEND = -300, MA_DEVICE_NOT_STOPPED = -203, ##  Operation errors.
    MA_DEVICE_NOT_STARTED = -202, MA_DEVICE_ALREADY_INITIALIZED = -201,
    MA_DEVICE_NOT_INITIALIZED = -200, MA_LOOP = -107, ##  State errors.
    MA_INVALID_DEVICE_CONFIG = -106, MA_API_NOT_FOUND = -105, MA_NO_DEVICE = -104,
    MA_NO_BACKEND = -103, MA_SHARE_MODE_NOT_SUPPORTED = -102,
    MA_DEVICE_TYPE_NOT_SUPPORTED = -101, MA_FORMAT_NOT_SUPPORTED = -100, MA_MEMORY_ALREADY_MAPPED = -52, ##  General miniaudio-specific errors.
    MA_CANCELLED = -51, MA_IN_PROGRESS = -50, MA_NO_HOST = -49,
    MA_CONNECTION_REFUSED = -48, MA_NOT_CONNECTED = -47, MA_ALREADY_CONNECTED = -46,
    MA_CONNECTION_RESET = -45, MA_SOCKET_NOT_SUPPORTED = -44,
    MA_ADDRESS_FAMILY_NOT_SUPPORTED = -43, MA_PROTOCOL_FAMILY_NOT_SUPPORTED = -42,
    MA_PROTOCOL_NOT_SUPPORTED = -41, MA_PROTOCOL_UNAVAILABLE = -40,
    MA_BAD_PROTOCOL = -39, MA_NO_ADDRESS = -38, MA_NOT_SOCKET = -37,
    MA_NOT_UNIQUE = -36, MA_NO_NETWORK = -35, MA_TIMEOUT = -34, MA_INVALID_DATA = -33,
    MA_NO_DATA_AVAILABLE = -32, MA_BAD_MESSAGE = -31, MA_NO_MESSAGE = -30,
    MA_NOT_IMPLEMENTED = -29, MA_TOO_MANY_LINKS = -28, MA_DEADLOCK = -27,
    MA_BAD_PIPE = -26, MA_BAD_SEEK = -25, MA_BAD_ADDRESS = -24, MA_ALREADY_IN_USE = -23,
    MA_UNAVAILABLE = -22, MA_INTERRUPT = -21, MA_IO_ERROR = -20, MA_BUSY = -19,
    MA_NO_SPACE = -18, MA_AT_END = -17, MA_DIRECTORY_NOT_EMPTY = -16,
    MA_IS_DIRECTORY = -15, MA_NOT_DIRECTORY = -14, MA_NAME_TOO_LONG = -13,
    MA_PATH_TOO_LONG = -12, MA_TOO_BIG = -11, MA_INVALID_FILE = -10,
    MA_TOO_MANY_OPEN_FILES = -9, MA_ALREADY_EXISTS = -8, MA_DOES_NOT_EXIST = -7,
    MA_ACCESS_DENIED = -6, MA_OUT_OF_RANGE = -5, MA_OUT_OF_MEMORY = -4,
    MA_INVALID_OPERATION = -3, MA_INVALID_ARGS = -2, MA_ERROR = -1, ##  A generic error.
    MA_SUCCESS = 0

type
    ma_sound_flags* = enum
        MA_SOUND_FLAG_STREAM                    = 0x00000001
        MA_SOUND_FLAG_DECODE                    = 0x00000002
        MA_SOUND_FLAG_ASYNC                     = 0x00000004
        MA_SOUND_FLAG_WAIT_INIT                 = 0x00000008
        MA_SOUND_FLAG_NO_DEFAULT_ATTACHMENT     = 0x00000010 # Do not attach to the endpoint by default. Useful for when setting up nodes in a complex graph system
        MA_SOUND_FLAG_NO_PITCH                  = 0x00000020 # Disable pitch shifting with ma_sound_set_pitch() and ma_sound_group_set_pitch(). This is an optimization.
        MA_SOUND_FLAG_NO_SPATIALIZATION         = 0x00000040 # Disable spatialization

type
  MaEngine* = object  
  MaDecoder* = object
  MaSound* = object

# MA Engine #
proc ma_engine_init*(pConfig: pointer;
                    pEngine: pointer):
                    ma_result {.cdecl, importc.}

proc ma_engine_uninit*(pEngine: pointer)
                      {.cdecl, importc.}

proc ma_engine_start*(pEngine: pointer)
                     {.cdecl, importc.}

proc ma_engine_stop*(pEngine: pointer)
                    {.cdecl, importc.}

proc ma_engine_play_sound*(pEngine: pointer;
                          pFilePath: cstring;
                          pGroup: pointer): 
                          ma_result {.cdecl, importc.}

proc ma_engine_read_pcm_frames*(pEngine: pointer;
                               pFramesOut: pointer;
                               frameCount: ma_uint64;
                               pFramesRead: ptr ma_uint64):
                               ma_result {.cdecl, importc.}

proc ma_engine_get_time*(pEngine: pointer):
                        ma_uint64 {.cdecl, importc.}

proc ma_engine_set_time*(pEngine: pointer;
                        globalTime: ma_uint64):
                        ma_result {.cdecl, importc.}

proc ma_engine_get_node_graph*(pEngine: pointer):
                              pointer {.cdecl, importc.}

proc ma_engine_get_resource_manager*(pEngine: pointer):
                                    pointer {.cdecl, importc.}

proc ma_engine_get_device*(pEngine: pointer):
                          pointer {.cdecl, importc.}

proc ma_engine_get_log*(pEngine: pointer):
                       pointer {.cdecl, importc.}

proc ma_engine_get_endpoint*(pEngine: pointer):
                            pointer {.cdecl, importc.}

proc ma_engine_get_sample_rate*(pEngine: pointer):
                               ma_uint32 {.cdecl, importc.}

proc ma_engine_get_channels*(pEngine: pointer):
                            ma_uint32 {.cdecl, importc.}

proc ma_engine_set_volume*(pEngine: pointer;
                          volume: float):
                          ma_result {.cdecl, importc.}

proc ma_engine_set_gain_db*(pEngine: pointer;
                           gainDB: float):
                           ma_result {.cdecl, importc.}


# MA Decoder #
proc ma_decoder_init_memory*(pData: pointer;
                            dataSize: csize_t;
                            pConfig: pointer;
                            pDecoder: pointer):
                            ma_result {.cdecl, importc.}

proc ma_decoder_uninit*(pDecoder: pointer):
                        ma_result {.cdecl, importc.}


# MA Sound #
proc ma_sound_init_from_data_source*(pEngine: pointer;
                                     pDataSource: pointer;
                                     flags: uint32;
                                     pGroup: pointer;
                                     pSound: pointer): 
                                     ma_result {.cdecl, importc.}

proc ma_sound_init_from_file*(pEngine: pointer;
                             pDataSource: pointer;
                             flags: uint32;
                             pGroup: pointer;
                             pDoneFence: pointer;
                             pSound: pointer): 
                             ma_result {.cdecl, importc.}     

proc ma_sound_uninit*(pSound: pointer)
                     {.cdecl, importc.}

proc ma_sound_start*(pSound: pointer): 
                    ma_result {.cdecl, importc.}

proc ma_sound_stop*(pSound: pointer):
                    ma_result {.cdecl, importc.}

proc ma_sound_set_volume*(pSound: pointer;
                         volume: float)
                         {.cdecl, importc.}

proc ma_sound_get_volume*(pSound: pointer):
                         float {.cdecl, importc.}

proc ma_sound_set_pitch*(pSound: pointer;
                        pitch: float)
                        {.cdecl, importc.}

proc ma_sound_get_pitch*(pSound: pointer):
                         float {.cdecl, importc.}

proc ma_sound_set_spatialization_enabled*(pSound: pointer;
                                         enabled: ma_bool32)
                                         {.cdecl, importc.}

proc ma_sound_is_spatialization_enabled*(pSound: pointer):
                                        ma_bool32 {.cdecl, importc.}

proc ma_sound_get_time_in_pcm_frames*(pSound: pointer):
                                     ma_uint64 {.cdecl, importc.}

proc ma_sound_get_time_in_milliseconds*(pSound: pointer):
                                       ma_uint64 {.cdecl, importc.}

proc ma_sound_get_data_format*(pSound: pointer;
                              pFormat: pointer;
                              pChannels: ma_uint32;
                              pSampleRate: ma_uint32;
                              pChannelMap: pointer;
                              channelMapCap: csize_t):
                              ma_result {.cdecl, importc.}

proc ma_sound_get_data_source*(pSound: pointer):
                              pointer {.cdecl, importc.}

proc ma_sound_get_engine*(pSound: pointer):
                         pointer {.cdecl, importc.}

proc ma_sound_seek_to_pcm_frame*(pSound: pointer;
                                frameIndex: ma_uint64):
                                ma_result {.cdecl, importc.}

proc ma_sound_set_looping*(pSound: pointer;
                          isLooping: ma_bool32)
                          {.cdecl, importc.}

proc ma_sound_is_looping*(pSound: pointer):
                         ma_bool32 {.cdecl, importc.}

proc ma_sound_is_playing*(pSound: pointer):
                         ma_bool32 {.cdecl, importc.}

proc ma_sound_at_end*(pSound: pointer):
                     ma_bool32 {.cdecl, importc.}

# MA size #
proc ma_engine_size*(): 
                    csize_t {.cdecl, importc.}

proc ma_decoder_size*(): 
                    csize_t {.cdecl, importc.}

proc ma_sound_size*(): 
                    csize_t {.cdecl, importc.}


when defined(basic): # Easy ass wrapper, we don't really use this tho :p
  proc play_sound_from_file*(file: cstring) 
                            {.cdecl, importc.} 
  
  proc play_sound_from_data*(data: pointer;
                            size: cint)
                            {.cdecl, importc.} 


