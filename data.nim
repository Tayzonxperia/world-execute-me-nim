import posix, os, strutils, strformat, macros



const
    CWD*            = staticExec("pwd")
    DATA_DIR*       = if CWD != "": CWD & "/data" else: "/dev/null"
    TMP_DIR*        = "/tmp/mili"

proc getCompileTime(file: string): string {.compileTime.} =
  if fileExists(file):
    return readFile(TMP_DIR & "/" & file)
  else:
    return "null"
    #quit("File not found: " & file)

const
    PROGNAME*       = static: getCompileTime("progname.tmp")
    VERSION*        = static: getCompileTime("version.tmp")
    AUDIO_BACKEND*  = static: getCompileTime("audio_backend.tmp")

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
    

#[ The compile time logger ]#

type CTlevel = enum
    ctInfo, ctWarn, ctError, ctTrace


proc logCompile(lvl: CTlevel, text: string) {.compileTime.} =
    if lvl == ctInfo:
        echo(fmt"Nim:[{BRIGHT_WHITE}{lvl}{RESET}] ==> {BRIGHT_WHITE}{text}{RESET}" & "\n")
    elif lvl == ctWarn:
        echo(fmt"Nim:[{BRIGHT_YELLOW}{lvl}{RESET}] ==> {BRIGHT_YELLOW}{text}{RESET}" & "\n")
    elif lvl == ctError:
        echo(fmt"Nim:[{BRIGHT_RED}{lvl}{RESET}] ==> {BRIGHT_RED}{text}{RESET}" & "\n")
    elif lvl == ctTrace:
        echo(fmt"Nim:[{BRIGHT_CYAN}{lvl}{RESET}] ==> {BRIGHT_CYAN}{text}{RESET}" & "\n")


template ctTrace*(text: string) =
    if defined debug:
        logCompile(ctTrace, text)
    else:
        discard

template ctInfo*(text: string) =
    logCompile(ctInfo, text)

template ctWarn*(text: string) =
    logCompile(ctWarn, text)
    
template ctError*(text: string) =
    logCompile(ctError, text)
    quit("Critical compile time error! Aborting...", 1)


macro ctASTdmp*(text: static[string], ast: untyped): untyped =
    echo("\nAST Dump: " & text & "\n" & ast.treeRepr & "\n")
    return ast #[ Dumps abstract syntax tree, cos why not ]#


#[ Data embedder ]#

type 
  ASSETreg* = tuple[name, data, filename: string]

proc zstData(file: string): string {.compileTime.} =
    const ZSTD_CMD = "zstd -k --adapt --auto-threads=logical --no-progress "

    if not dirExists(TMP_DIR): createDir(TMP_DIR) else: ctInfo("Using existing directory: " & TMP_DIR)
    #[ /tmp is nuked on reboot, so if our dir already exists, why keep re-nuking it... ]#

    if not fileExists(file): ctError("File not found: " & file)
    ctInfo("Data located: " & file & "\nPreparing to compress...")

    let filename = staticExec("basename " & file); ctTrace("Data filename: " & filename)

    ctInfo("Buffering data..."); discard staticExec("cp " & DATA_DIR & "/" & filename & " " & TMP_DIR & "/")

    let new_filename = TMP_DIR & "/" & filename

    let compress_cmd = ZSTD_CMD & new_filename & " -o " & new_filename & ".zst.tmp"
    ctInfo("Compressing data..."); discard staticExec(compress_cmd)

    if not fileExists(new_filename & ".zst.tmp"): echo(staticExec("rm -f " & TMP_DIR & "/*")); ctError("File not found: " & new_filename)

    ctInfo("Data compressed successfully!")

    result = readFile(new_filename & ".zst.tmp"); ctTrace("Resulting data: " & $result)
    echo("Cleaning up...\n" & staticExec("rm -f " & TMP_DIR & "/*"))

    if not cstring($result).isNil:
        ctTrace($result & " is not Nil!")
        return result
    else:
        ctError("Data is Nil, aborting due to data corruption...")


macro zstandardCompressDir*(dir: static[string]): untyped =
    let assetFiles = staticExec("ls -1 " & dir).splitLines()
    var stmts: seq[NimNode] = @[]
    var identPrefix = ""
    for file in assetFiles:
        if file.endsWith(".flac") or file.endsWith(".ogg") or file.endsWith(".mp3"):
            identPrefix = "_AUDIO"
        elif file.endsWith(".mkv") or file.endsWith(".webm") or file.endsWith(".mp4"):
            identPrefix = "_VIDEO"
        elif file.endsWith(".png") or file.endsWith(".jpg") or file.endsWith(".jpeg"):
            identPrefix = "_IMAGE"
        elif file.endsWith(".bin") or file.endsWith(".pak") or file.endsWith(".o"):
            identPrefix = "_BINARY"
        elif file.endsWith(".txt") or file.endsWith(".md"):
            identPrefix = "_TEXT"
        else:
            identPrefix = "_DATA"
        let constIdentStr = file.replace(".", "_").replace("-", "_") & identPrefix
        let idNode = ident(constIdentStr)
        let fullPath = dir & "/" & file
        let blob = zstData(`fullPath`)
        stmts.add(quote do:
            const `idNode` = `blob`
            assets.add((name: `idNode`.astToStr, data: `blob`, filename: `file`)))
    result = newStmtList(stmts) #[ What this does, is when we compress our file, we only
    get a blob back, but we need to store it as a constant. So using this, with our seq,
    we store 3 entries: name (The idNode, for a file named cat.png it would be named 
    cat_png_IMAGE), blob (The actual binary compressed blob) and filename (The filename
    of the file that was converted) - This is great, because we have a CTE compresser ]#

var assets*: seq[ASSETreg] = @[]


