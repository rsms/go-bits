// +build amd64

package bits

//go:noescape
func popcountInit() bool

//go:noescape
func PopcountIsIntrinsic() bool

//go:noescape
func PopcountUint64(v uint64) int

func PopcountUint(v uint) int { return PopcountUint64(uint64(v)) }

//go:noescape
func Bitindex(bmap, bitpos uint) int
