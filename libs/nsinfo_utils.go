package nsinfo

import (
    "os"
)

func IsRoot() bool {
    return os.Getuid() == 0
}
