function selectionSort(array) {
    var min,
        idx,
        temp;
    for (var i = 0; i < array.length; i += 1) {
       min = Infinity;
       for (var j = i + 1; j < array.length; j += 1) {
           if (min > array[j]) {
               min = array[j];
               idx = j;
           }
       }
       temp = array[idx];
       array[idx] = array[i];
       array[i] = temp;
    }
    return array;
}

selectionSort(array);
