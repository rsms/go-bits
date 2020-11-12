// +build amd64

// This implements popcount and bitindex using dedicated POPCNTQ instruction
// when available and a fast fallback implementation when not.
//
// To test the fallback implementation, find the following line and comment it out:
// MOVB CX, hasPopcnt(SB)
// This line is where we store whether the CPU has POPCNT support or not; disabling
// it means hasPopcnt==0 and the fallback implementation will be used.
//

#include "textflag.h"

// define a writable global byte "hasPopcnt", initialized to 0x00.
// See https://golang.org/doc/asm#directives for details on DATA and GLOBL syntax.
DATA  hasPopcnt+0x00(SB)/1, $0x00
GLOBL hasPopcnt(SB), NOPTR, $1

TEXT ·popcountInit(SB),NOSPLIT,$0
  // Support is indicated via the CPUID.01H:ECX.POPCNT[Bit 23] flag
  XORQ AX, AX
  INCL AX
  CPUID
  SHRQ $23, CX
  ANDQ $1, CX
  MOVB CX, hasPopcnt(SB)  // bits.hasPopcnt = CX
  // Note: this function is assumed to return a bool (which is ignored by callers)
  // but does not store to the stack here. That is fine since the Go calling convention
  // is for the called to allocate stack space for return values.
  RET

TEXT ·PopcountIsIntrinsic(SB),NOSPLIT,$0
  MOVB hasPopcnt(SB), AX
  MOVB AX, ret+0(FP)
  RET


// fallback implementation of popcount from math.bits
// func OnesCount64(x uint) int {
//   const m0 = 0x5555555555555555 // 01010101 ...
//   const m1 = 0x3333333333333333 // 00110011 ...
//   const m2 = 0x0f0f0f0f0f0f0f0f // 00001111 ...
//   const m = 1<<64 - 1
//   x = x>>1&(m0&m) + x&(m0&m)
//   x = x>>2&(m1&m) + x&(m1&m)
//   x = (x>>4 + x) & (m2 & m)
//   x += x >> 8
//   x += x >> 16
//   x += x >> 32
//   return int(x) & (1<<7 - 1)
// }
// This macro clobbers registers: AX, CX, DX
#define POPCNT_FALLBACK() \
  MOVQ  AX, CX; \
  SHRQ  $1, AX; \
  MOVQ  $0x5555555555555555, DX; \
  ANDQ  DX, AX; \
  ANDQ  CX, DX; \
  ADDQ  DX, AX; \
  MOVQ  AX, CX; \
  SHRQ  $2, AX; \
  MOVQ  $0x3333333333333333, DX; \
  ANDQ  AX, DX; \
  MOVQ  $0x3333333333333333, AX; \
  ANDQ  CX, AX; \
  ADDQ  DX, AX; \
  MOVQ  AX, CX; \
  SHRQ  $4, AX; \
  ADDQ  CX, AX; \
  MOVQ  $0x0f0f0f0f0f0f0f0f, CX; \
  ANDQ  AX, CX; \
  MOVQ  CX, AX; \
  SHRQ  $8, CX; \
  ADDQ  CX, AX; \
  MOVQ  AX, CX; \
  SHRQ  $16, AX; \
  ADDQ  CX, AX; \
  MOVQ  AX, CX; \
  SHRQ  $32, AX; \
  ADDQ  CX, AX; \
  ANDQ  $127, AX


// func PopcountUint64(v int) int
TEXT ·PopcountUint64(SB),NOSPLIT,$0-8
  MOVQ    8(SP), AX
  MOVB hasPopcnt(SB), BX
  CMPB  BX, $0
  JEQ fallback
  // POPCNT is supported
  POPCNTQ AX, AX
  JMP end
fallback:
  // POPCNT not supported
  POPCNT_FALLBACK()
end:
  MOVQ  AX, 16(SP)
  RET


// func Bitindex(bmap, bitpos uint) uint
TEXT ·Bitindex(SB),NOSPLIT,$0-16
  // return popcount(bmap & (bitpos - 1))
  MOVQ  16(SP), AX  // AX = arg(bitpos)
  DECQ  AX          // AX--
  MOVQ  8(SP), CX   // CX = arg(bmap)
  ANDQ  CX, AX      // AX = AX & CX

  MOVB hasPopcnt(SB), CX
  CMPB  CX, $0
  JEQ fallback
  // POPCNT is supported
  POPCNTQ AX, AX    // AX = popcount AX
  JMP end
fallback:
  // POPCNT not supported
  POPCNT_FALLBACK()
end:
  MOVQ  AX, 24(SP)  // return(0) = AX
  RET

