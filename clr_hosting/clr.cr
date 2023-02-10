# References
# - https://blog.ropnop.com/hosting-clr-in-golang/ -> has heavily inspired this code
# - https://github.com/HavocFramework/Havoc
# - https://gist.github.com/xpn/e95a62c6afcf06ede52568fcd8187cc2
# - https://github.com/ropnop/go-clr
# - https://github.com/crystal-lang/
# - Microsoft doc
# - https://crystal-lang.org/api/
# - Crystal community Discord
# - https://crystal-lang.org/api/1.7.2/OptionParser.html

require "colorize"
require "option_parser"

lib LibC
    alias REFCLSID = Pointer(LibC::GUID)
    alias REFIID = Pointer(LibC::GUID)

    struct ICLRMetaHostVtbl
        queryInterface : Pointer(UInt32)
        addRef : Pointer(UInt32)
        release : Pointer(UInt32)
        getRuntime : Pointer(UInt32)
        getVersionFromFile : Pointer(UInt32)
        enumerateInstalledRuntimes : Pointer(UInt32)
        enumerateLoadedRuntimes : Pointer(UInt32)
        requestRuntimeLoadedNotification : Pointer(UInt32)
        queryLegacyV2RuntimeBinding : Pointer(UInt32)
        exitProcess : Pointer(UInt32)
    end

    struct ICLRMetaHost
        vtbl : Pointer(ICLRMetaHostVtbl)
    end

    struct IEnumUnknown
        vtbl : Pointer(IEnumUnknownVtbl)
    end

    struct IEnumUnknownVtbl
        queryInterface : Pointer(UInt32)
        addRef : Pointer(UInt32)
        release : Pointer(UInt32)
        _next : Pointer(UInt32)
        skip : Pointer(UInt32)
        reset : Pointer(UInt32)
        clone : Pointer(UInt32)
    end

    struct IUnknown
        vtbl : Pointer(IUnknownVtbl)
    end

    struct IUnknownVtbl
        queryInterface : Pointer(UInt32)
        addRef : Pointer(UInt32)
        release : Pointer(UInt32)
    end

    struct ICLRRuntimeInfo
        vtbl : Pointer(ICLRRuntimeInfoVtbl)
    end

    struct ICLRRuntimeInfoVtbl
        queryInterface : Pointer(UInt32)
        addRef : Pointer(UInt32)
        release : Pointer(UInt32)
        getVersionString : Pointer(UInt32)
        getRuntimeDirectory : Pointer(UInt32)
        isLoaded : Pointer(UInt32)
        loadErrorString : Pointer(UInt32)
        loadLibrary : Pointer(UInt32)
        getProcAddress : Pointer(UInt32)
        getInterface : Pointer(UInt32)
        isLoadable : Pointer(UInt32)
        setDefaultStartupFlags : Pointer(UInt32)
        getDefaultStartupFlags : Pointer(UInt32)
        bindAsLegacyV2Runtime : Pointer(UInt32)
        isStarted : Pointer(UInt32)
    end

    struct ICLRRuntimeHost
        vtbl : Pointer(ICLRRuntimeHostVtbl)
    end

    struct ICLRRuntimeHostVtbl
        queryInterface : Pointer(UInt32)
        addRef : Pointer(UInt32)
        release : Pointer(UInt32)
        start : Pointer(UInt32)
        stop : Pointer(UInt32)
        setHostControl : Pointer(UInt32)
        getCLRControl : Pointer(UInt32)
        unloadAppDomain : Pointer(UInt32)
        executeInAppDomain : Pointer(UInt32)
        getCurrentAppDomainId : Pointer(UInt32)
        executeApplication : Pointer(UInt32)
        executeInDefaultAppDomain : Pointer(UInt32)
    end

    CLSID_CLRMetaHost = LibC::GUID.new(UInt32.new(0x9280188d), UInt16.new(0xe8e), UInt16.new(0x4867), StaticArray[ UInt8.new(0xb3), UInt8.new(0xc), UInt8.new(0x7f), UInt8.new(0xa8), UInt8.new(0x38), UInt8.new(0x84), UInt8.new(0xe8), UInt8.new(0xde) ])
    IID_ICLRMetaHost = LibC::GUID.new(UInt32.new(0xD332DB9E), UInt16.new(0xB9B3), UInt16.new(0x4125), StaticArray[ UInt8.new(0x82), UInt8.new(0x07), UInt8.new(0xA1), UInt8.new(0x48), UInt8.new(0x84), UInt8.new(0xF5), UInt8.new(0x32), UInt8.new(0x16) ])
    IID_ICLRRuntimeInfo = LibC::GUID.new(UInt32.new(0xBD39D1D2), UInt16.new(0xBA2F), UInt16.new(0x486a), StaticArray[ UInt8.new(0x89), UInt8.new(0xB0), UInt8.new(0xB4), UInt8.new(0xB0), UInt8.new(0xCB), UInt8.new(0x46), UInt8.new(0x68), UInt8.new(0x91) ])
    IID_ICLRRuntimeHost = LibC::GUID.new(UInt32.new(0x90F1A06C), UInt16.new(0x7712), UInt16.new(0x4762), StaticArray[ UInt8.new(0x86), UInt8.new(0xB5), UInt8.new(0x7A), UInt8.new(0x5E), UInt8.new(0xBA), UInt8.new(0x6B), UInt8.new(0xDB), UInt8.new(0x02) ])
    CLSID_CLRRuntimeHost = LibC::GUID.new(UInt32.new(0x90F1A06E), UInt16.new(0x7712), UInt16.new(0x4762), StaticArray[ UInt8.new(0x86), UInt8.new(0xB5), UInt8.new(0x7A), UInt8.new(0x5E), UInt8.new(0xBA), UInt8.new(0x6B), UInt8.new(0xDB), UInt8.new(0x02) ])
    S_OK = 0
end

targetDll = ""
className = ""
entrypoint = ""
arguments = ""

# Source: https://crystal-lang.org/api/1.7.2/OptionParser.html
OptionParser.parse do |parser|
    parser.banner = "Usage: clr.exe [arguments]"
    parser.on("--dll NAME", "The DLL to run") { |name| targetDll = name }
    parser.on("--class NAME", "The DLL namespace.class to run") { |name| className = name }
    parser.on("--method NAME", "The method to run in the DLL") { |name| entrypoint = name }
    parser.on("--arg NAME", "The arguments to pass to the method") { |name| arguments = name }
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
end

# DLL where the "CLRCreateInstance" function is defined, used to create a CLR instance
dllName = "MSCorEE.dll"

# Reference to convert dllName to a WSTR: https://github.com/crystal-lang/crystal/blob/f0bd16a8dcc43f02ba118d7f0b912eab3251b927/src/crystal/system/windows.cr
# Loading the library
pMscoree = LibC.LoadLibraryExW(dllName.to_utf16.to_unsafe, nil, 0)

# Getting the "CLRCreateInstance" function pointer
pClrCreateInstance = LibC.GetProcAddress(pMscoree, "CLRCreateInstance")
cLRCreateInstance = Proc(LibC::REFCLSID, LibC::REFIID, Pointer(Pointer(LibC::ICLRMetaHost)), UInt32).new(pClrCreateInstance, Pointer(Void).null)

pCLRMetaHost = Pointer(LibC::ICLRMetaHost).null
result = cLRCreateInstance.call(pointerof(LibC::CLSID_CLRMetaHost), pointerof(LibC::IID_ICLRMetaHost), pointerof(pCLRMetaHost))

if result == LibC::S_OK
    puts "[+] Succesfully created the CLR instance".colorize(:green)
else
    puts "[-] Couldn't create the CLR instance".colorize(:red)
    exit
end

vtblCLRMetaHost = pCLRMetaHost.value.vtbl.value
pAvailableRuntimes = Pointer(LibC::IEnumUnknown).null

# Getting the "EnumerateInstalledRuntimes" function pointer
enumerateInstalledRuntimes = Proc(Pointer(Pointer(LibC::ICLRMetaHost)), Pointer(Pointer(LibC::IEnumUnknown)), UInt32).new(vtblCLRMetaHost.enumerateInstalledRuntimes.as(Pointer(Void)), Pointer(Void).null)
result = enumerateInstalledRuntimes.call(pointerof(pCLRMetaHost), pointerof(pAvailableRuntimes))

if result == LibC::S_OK
    puts "[+] Succesfully enumerated installed runtimes".colorize(:green)
else
    puts "[-] Couldn't enumerate installed runtimes".colorize(:red)
    exit
end

vtblInstalledRuntimes = pAvailableRuntimes.value.vtbl.value.as(LibC::IEnumUnknownVtbl)

# Getting the "Next" function pointer
enumRuntime = Pointer(LibC::ICLRRuntimeInfo).null
tmp = Pointer(UInt32).new(0)

_next = Proc(Pointer(LibC::IEnumUnknown), Int32, Pointer(Pointer(LibC::ICLRRuntimeInfo)), Pointer(UInt32), UInt32).new(vtblInstalledRuntimes._next.as(Pointer(Void)), Pointer(Void).null)

name = LibC::LPWSTR.malloc(2048)
bytes = LibC::DWORD.new(2048)
vtblEnumRuntime = Pointer(Void).null
table = Array(Tuple(String, LibC::LPWSTR, Pointer(LibC::ICLRRuntimeInfo))).new()

i = 0
while 1
    result = _next.call(pAvailableRuntimes.as(Pointer(LibC::IEnumUnknown)), 1, pointerof(enumRuntime), tmp)

    if result != LibC::S_OK
        break
    end

    # Getting the "GetVersionString" function pointer
    vtblEnumRuntime = enumRuntime.value.vtbl.value

    getVersionString = Proc(Pointer(LibC::ICLRRuntimeInfo), LibC::LPWSTR, Pointer(LibC::DWORD), UInt32).new(vtblEnumRuntime.getVersionString.as(Pointer(Void)), Pointer(Void).null)
    result = getVersionString.call(enumRuntime, name, pointerof(bytes))

    if result != LibC::S_OK
        puts "[-] Couldn't get runtime version string".colorize(:red)
    end

    frameworkName = ""

    j = 0
    while ((name + j).value != 0)
        frameworkName += (name + j).value.unsafe_chr
        j += 1
    end

    table.push({frameworkName, name, enumRuntime})
    i += 1
end

# Choosing the last runtime
enumRuntime = table[-1][2]
puts "[*] Using this runtime: " + table[-1][0]

if vtblEnumRuntime.is_a?(LibC::ICLRRuntimeInfoVtbl)
    # Getting the "GetInterface" function pointer
    pRuntimeHost = Pointer(LibC::ICLRRuntimeHost).null

    getInterface = Proc(Pointer(LibC::ICLRRuntimeInfo), LibC::REFCLSID, LibC::REFCLSID, Pointer(Pointer(LibC::ICLRRuntimeHost)), UInt32).new(vtblEnumRuntime.getInterface.as(Pointer(Void)), Pointer(Void).null)
    result = getInterface.call(enumRuntime, pointerof(LibC::CLSID_CLRRuntimeHost), pointerof(LibC::IID_ICLRRuntimeHost), pointerof(pRuntimeHost))

    if result == LibC::S_OK
        puts "[+] Succesfully get the runtime interface".colorize(:green)
    else
        puts "[-] Couldn't get the runtime interface".colorize(:red)
        exit
    end

    vtblRuntimeHost = pRuntimeHost.value.vtbl.value

    # Getting the "Start" function pointer
    start = Proc(Pointer(LibC::ICLRRuntimeHost), UInt32).new(vtblRuntimeHost.start.as(Pointer(Void)), Pointer(Void).null)
    result = start.call(pRuntimeHost)

    if result == LibC::S_OK
        puts "[+] Succesfully started CLR".colorize(:green)
    else
        puts "[-] Couldn't start CLR".colorize(:red)
        exit
    end

    # Getting the "ExecuteInDefaultAppDomain" function pointer
    returnValue = Pointer(UInt16).null

    executeInDefaultAppDomain = Proc(Pointer(LibC::ICLRRuntimeHost),LibC::LPWSTR,LibC::LPWSTR,LibC::LPWSTR,LibC::LPWSTR,Pointer(UInt16), UInt32).new(vtblRuntimeHost.executeInDefaultAppDomain.as(Pointer(Void)), Pointer(Void).null)
    result = executeInDefaultAppDomain.call(pRuntimeHost, targetDll.to_utf16.to_unsafe, className.to_utf16.to_unsafe, entrypoint.to_utf16.to_unsafe, arguments.to_utf16.to_unsafe, returnValue)

    if result == LibC::S_OK
        puts "[+] Succesfully executed the DLL".colorize(:green)
    else
        puts "[-] Couldn't execute the DLL".colorize(:red)
        exit
    end
end
