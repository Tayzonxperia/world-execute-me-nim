import posix, os, strutils, strformat



let 
    cwd                 = getCurrentDir()
    main_file           = cwd & "/main.nim"
    build_dir           = cwd & "/Build"

const 
    PROGRAM             = "world.execute(me); [Console Music Video]"
    FILENAME            = "world-execute-cmv"
    VERSION             = readFile("config/version")
    BUILD_FLAGS_C       = "-march=native -mtune=native -Os " &
              "-flto -pipe -fmerge-all-constants " &
              "-fno-strict-aliasing -fno-ident -fno-rtti " &
              "-fno-asynchronous-unwind-tables " &
              "-fno-unwind-tables -ffunction-sections " &
              "-fdata-sections -s"

    BUILD_FLAGS_LD      = "-Wl,-Os,-flto,--gc-sections,--build-id=none"

    BUILD_FLAGS_DEFINE  = "--threads:on --opt:size " &
                "-x:off -a:off --debuginfo:off " &
                "--stackTrace:off --lineTrace:off " &
                "-d:release --mm:arc -d:strip -d:lto " &
                "--maxLoopIterationsVM=999999999"

author = "Wakana Kisarazu"
packagename = PROGRAM
version = VERSION
description = """world.execute(me); - Rewritten in Nim:

With custom bindings to miniaudio, for performance and
control, this ensures a smooth console music video for
this wonderful song made by Mili :3"""
backend = "C"
license = "GPL 2"
mode = ScriptMode.Verbose

const
    CLEAR*              = "\e[2J\e[H"
    RESET*              = "\x1b[0m"
    BOLD*               = "\x1b[1m"
    RED*                =  "\x1b[31m"
    GREEN*              = "\x1b[32m"
    YELLOW*             = "\x1b[33m"
    BLUE*               = "\x1b[34m"
    MAGENTA*            = "\x1b[35m"
    CYAN*               = "\x1b[36m"
    WHITE*              = "\x1b[37m"
    BRIGHT_RED*         = "\x1b[91m"
    BRIGHT_GREEN*       = "\x1b[92m"
    BRIGHT_YELLOW*      = "\x1b[93m"
    BRIGHT_BLUE*        = "\x1b[94m"
    BRIGHT_MAGENTA*     = "\x1b[95m"
    BRIGHT_CYAN*        = "\x1b[96m"
    BRIGHT_WHITE*       = "\x1b[97m"

type Blevel = enum
    bInfo, bOkay, bWarn, bError, bTrace


proc logBuild(lvl: Blevel, text: string) {.compileTime.} =
    if lvl == bInfo:
        echo(fmt"Nim:[{BRIGHT_WHITE}{lvl}{RESET}] ==> {BRIGHT_WHITE}{text}{RESET}" & "\n")
    elif lvl == bOkay:
        echo(fmt"Nim:[{BRIGHT_GREEN}{lvl}{RESET}] ==> {BRIGHT_WHITE}{text}{RESET}" & "\n")
    elif lvl == bWarn:
        echo(fmt"Nim:[{BRIGHT_YELLOW}{lvl}{RESET}] ==> {BRIGHT_YELLOW}{text}{RESET}" & "\n")
    elif lvl == bError:
        echo(fmt"Nim:[{BRIGHT_RED}{lvl}{RESET}] ==> {BRIGHT_RED}{text}{RESET}" & "\n")
    elif lvl == bTrace:
        echo(fmt"Nim:[{BRIGHT_CYAN}{lvl}{RESET}] ==> {BRIGHT_CYAN}{text}{RESET}" & "\n")


template bInfo*(text: string) =
    logBuild(bInfo, text)

template bWarn*(text: string) =
    logBuild(bWarn, text)

template bError*(text: string) =
    logBuild(bError, text)

template bOkay*(text: string) =
    logBuild(bOkay, text)

template bTrace*(text: string) =
    if defined debug:
        logBuild(bTrace, text)
    else:
        discard


exec "clear"; bInfo("Checking host system ABI..."); when not defined(Linux) and not defined(amd64) or defined(i368):
  bWarn(PROGRAM & " is not expected to work on ABI's other than standard Linux x86/x86_64"); sleep(2)

bInfo("Starting compilation of " & BOLD & MAGENTA & PROGRAM & " " & RESET & CYAN & VERSION & RESET &
" with Nim: " & NimVersion & " at " & CompileTime & " (" & CompileDate & ")")

let command = "nim c --out:\"" & build_dir & "/" & FILENAME & "\"" &
" " & BUILD_FLAGS_DEFINE & " --app:console --passC:\"" & BUILD_FLAGS_C &
"\"" & " --passL:\"" & BUILD_FLAGS_LD & "\" " & main_file

try:
    bInfo("Compiling " & PROGRAM & " (" & FILENAME & ") binary...")
    exec command; bOkay("Compilation completed successfully!\n")
    if fileExists("config/symlink"):
        bInfo("Symlinking..."); exec "ln -sfv " & build_dir & "/" & FILENAME & " " & cwd & "/main"
except CatchableError as e:
    bError("Error: Compilation failed due to error (output => " & e.msg & ")")

