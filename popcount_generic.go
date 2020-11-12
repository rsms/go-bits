// +build !amd64

package bits

import "math/bits"

func popcountInit() {}

func PopcountIsIntrinsic() bool { return false }
func PopcountUint(v uint) int { return bits.OnesCount(v) }
func PopcountUint64(v uint64) int { return bits.OnesCount64(v) }

func Bitindex(bmap, bitpos uint) int {
  return PopcountUint(bmap & (bitpos - 1))
}
