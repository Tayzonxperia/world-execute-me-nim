import posix, os, strutils, strformat
import "data"


type Color* = enum
    Green, Yellow, Red,

proc basicConsole*(text: string, delayMS: int, color: Color) =
    var prefix = "[Console]"
    var str: string

    case color
    of Green:
        str = fmt"{BRIGHT_GREEN}{text}{RESET}"
    of Yellow:
        str = fmt"{BRIGHT_GREEN}{text}{RESET}"
    of Red:
        str = fmt"{BRIGHT_RED}{text}{RESET}"

    stdout.write(prefix)
    for c in str:
        stdout.write(c)
        flushFile(stdout)
        sleep(delayMS)
    stdout.write("\n")
    flushFile(stdout)        

proc basicConsole*(text: string, delayMS: int) =
    var prefix = "[Console]"
    var str: string

    str = fmt"{BRIGHT_GREEN}{text}{RESET}"

    stdout.write(prefix)
    for c in str:
        stdout.write(c)
        flushFile(stdout)
        sleep(delayMS)
    stdout.write("\n")
    flushFile(stdout)        

proc basicConsole*(text: string) =
    var prefix = "[Console]"
    var str: string

    str = fmt"{BRIGHT_GREEN}{text}{RESET}"

    stdout.write(prefix)
    for c in str:
        stdout.write(c)
        flushFile(stdout)
        sleep(10)
    stdout.write("\n\n")
    flushFile(stdout)    


proc simulateLoad(msg: string, filler: char, size: int) =
    stdout.write(msg & "\n[" & BRIGHT_WHITE)
    
    for c in 1..size:
        if c != size:
            stdout.write(filler)
        else:
            stdout.write(filler & "]" & RESET & "\n\n")

proc simulateLoadSpin(msg: string, size: int, delayMS: int = 50) =
    const spinner = ["|", "/", "-", "\\"]

    for i in 0..size:
        let percent = (i * 100) div size
        let filled = i * 30 div size
        let spin = spinner[i mod 4]

        stdout.write("\r", spin, " ", msg, ": [")
        stdout.write("█".repeat(filled))
        stdout.write("░".repeat(30 - filled))
        stdout.write("] ", percent, "%")
        stdout.flushFile()

        sleep(delayMS)

    stdout.write("\n\n")


proc `1`*(text: string) =
    basicConsole(text)
    let data = readFile(CWD & "/data/fetch.txt")
    echo(data & "\n")

proc `2`*(text: string) = 
    basicConsole(text)
    simulateLoad("Encypting: ", '*', 35)

proc `3`*(text: string) =
    basicConsole(text)
    stdout.write(BRIGHT_YELLOW & "proc objectCreation*[T](obj: T): World = \n\n" & RESET)

proc `4`*(text: string) =
    basicConsole(text)
    let data = readFile(CWD & "/data/object.txt")
    echo(BRIGHT_CYAN & data & RESET & "\n")
 
proc `5`*(text: string) =
    basicConsole(text)
    let data = readFile(CWD & "/data/error1.txt")
    echo(BRIGHT_RED & data & RESET & "\n")

proc `6`*(text: string) =
    basicConsole(text)
    simulateLoad("Setting world metadata... ", '*', 35)
    stdout.write(BRIGHT_CYAN & """
let world = alloc(sizeof(World))
world.addPerson(me)
world.addPerson(you)""" & "\n\n" & RESET)

proc `7`*(text: string) =
    basicConsole(text, 25); sleep(10)
    stdout.write(CLEAR)
    let data = readFile(CWD & "/data/world1.txt")
    stdout.write(BRIGHT_CYAN & "world.activateSimulation(world: World)\n" & data & RESET & "\n\n")

    
proc `8`*(text: string) =
    let data = readFile(CWD & "/data/world2.txt")
    simulateLoadSpin("Generating world", 200, 55)
    stdout.write(BRIGHT_CYAN & """
#[ Setting Default: 
Direct all inquires
to the Information 
Team regarding the
default settings ]#
world_cheats        =   false
world_force_exit    =   false
world_death_allow   =   false
world_allowdownload =   false
world_allowupload   =   false
world_limitsouls    =   4
server_logbans      =   true
server_logfile      =   true
server_logecho      =   true
# RCON settings
rcon_pw     =   "/DK3UR-RQ4U7C8D"
rcon_id     =   "?????"""" & data & RESET & "\n\n")