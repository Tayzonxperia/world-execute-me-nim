import posix, os, strutils
import "console", "data"



type LyricEvent* = object
    text*: string
    timeMs*: float64
    effect*: proc(text: string)
    fired*: bool

type LyricContext* = object
    lines*: seq[LyricEvent]
    title*: string
    lastIndex*: int

        
proc addLyricFx*(text, timestamp: string): proc(text: string) =
    if text == "" or timestamp == "": quit("Needs a proc")
    case timestamp
    of "00:00.03":
        return `1`
    of "00:01.33":
        return `2`
    of "00:05.16":
        return `3`
    of "00:07.19":
        return `4`
    of "00:09.75":
        return `5`
    of "00:10.90":
        return `6`
    of "00:12.47":
        return `7`
    of "00:16.04":
        return `8`
    #of "00:16.04":
        #return `4`
    else:
        return basicConsole

proc parseTimestamp(stamp: string): float64 =
    let parts = stamp.split(":"); if parts.len != 2:
        quit("Lyrics failed to parse", 1)

    let minutes = parseInt(parts[0])
    let secParts = parts[1].split('.')
    let seconds = parseInt(secParts[0])
    let centiSeconds = if secParts.len > 1: parseInt(secParts[1]) else: 0

    result = (minutes * 60 * 1000).float64 + (seconds * 1000).float64 + (centiSeconds * 10).float64


proc parseLyricFile*(content: string): LyricContext =
    result = LyricContext(lines: @[], title: content, lastIndex: 0)

    for line in content.splitLines():
        if line.strip() == "":
            continue

        if line.contains("]"):
            let bracketEnd = line.find(']')
            if bracketEnd > 0:
                let timestamp = line[1..<bracketEnd]
                let text = line[bracketEnd+1..^1]
                let effect = addLyricFx(text, timestamp)

                result.lines.add(LyricEvent(
                    text: text,
                    timeMs: parseTimestamp(timestamp),
                    effect: effect
                ))


proc getCurrentLyric*(context: var LyricContext, curTimeMs: float): string =
    for i in context.lastIndex..<context.lines.len:
        if curTimeMs >= context.lines[i].timeMs:
            if not context.lines[i].fired:
                context.lines[i].effect(context.lines[i].text)
                context.lines[i].fired = true
            context.lastIndex = i + 1
            return context.lines[i].text
        else:
            break
    return ""

