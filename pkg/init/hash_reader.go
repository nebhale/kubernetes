package init

import (
	"fmt"
	"hash"
	"io"
)

type HashReader struct {
	Reader io.ReadCloser
	Hash   hash.Hash
}

func (h HashReader) Sum() string {
	return fmt.Sprintf("%x", h.Hash.Sum(nil))
}

func (h HashReader) Read(p []byte) (n int, err error) {
	n, err = h.Reader.Read(p)
	h.Hash.Write(p[0:n])

	return n, err
}
