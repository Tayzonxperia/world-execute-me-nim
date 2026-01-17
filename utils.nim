import posix
import "miniaudio/miniaudio"

#[ This checks so we don't fall for OOM ]#
func checkIfNil*(p: pointer): bool =
    if p.isNil: return true

#[ This makes passing pointers easier ]#
template passPtr*(obj, body: untyped): untyped =
    cast[ptr obj](body)


#[ These convert PCM frames -> seconds and vise-versa
   For timekeeping, and lyric syncing... ]#

func framesToSecs*(frames: uint64, sampleRate: uint32): float64 =
    return float64(frames) / float64(sampleRate)

func secsToFrames*(seconds: float64, sampleRate: uint32): uint64 =
    return ma_uint64(seconds * float(sampleRate))

func secsToMillisecs*(seconds: float64): float64 =
    return seconds * 1000

#[ These convert ma_bool* and Nim's bool to eachother ]#

func maBoolToBool*[T: SomeInteger](maBoolean: T): bool =
    return maBoolean != 0

func boolToMaBool*[T: SomeInteger](boolean: bool): T =
    if boolean: 1 else: 0
