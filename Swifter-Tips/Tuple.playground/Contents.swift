// Before Tuple

func swapMe1<T>(a: inout T, b: inout T) {
    let temp = a
    a = b
    b = temp
}

// After Tuple

func swapMe2<T>(a: inout T, b: inout T) {
    (a, b) = (b, a)
}
