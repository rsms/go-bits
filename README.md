# bits

[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/rsms/go-bits.svg)][godoc]
[![PkgGoDev](https://pkg.go.dev/badge/github.com/rsms/go-bits)][godoc]
[![Go Report Card](https://goreportcard.com/badge/github.com/rsms/go-bits)](https://goreportcard.com/report/github.com/rsms/go-bits)

[godoc]: https://pkg.go.dev/github.com/rsms/go-bits

bit manipulation

```go
// PopcountUint returns the number of bits set in v
func PopcountUint(v uint) int
func PopcountUint64(v uint64) int

// Bitindex is equivalent to PopcountUint(bmap&(bitpos-1))
func Bitindex(bmap, bitpos uint) int

// PopcountIsIntrinsic returns true if popcount is implemented with a dedicated CPU instruction
func PopcountIsIntrinsic() bool
```
