function insertionSort(array) {
    var current,
        j;
    for (var i = 1; i < array.length; i += 1) {
        current = array[i];
        j = i - 1;
        while (j >= 0 && array[j] > current) {
            array[j + 1] = array[j];
            j -= 1;
        }
        array[j + 1] = current;
    }
    return array;
}

insertionSort(array);
