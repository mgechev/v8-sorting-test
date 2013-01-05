function bubbleSort(array) {
    var temp;
    for (var i = 0; i < array.length; i += 1) {
        for (var j = i; j > 0; j -= 1) {
            if (array[j] < array[j - 1]) {
                temp = array[j];
                array[j] = array[j - 1];
                array[j - 1] = temp;
            }
        }
    }
    return array;
}

bubbleSort(array);
