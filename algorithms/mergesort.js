var mergeSort = (function () {
    function merger(array, start, end) {
        if (Math.abs(end - start) <= 1) {
            return [];
        }
        var middle = Math.ceil((start + end) / 2);

        merger(array, start, middle);
        merger(array, middle, end);

        return merge(array, start, middle, end);
    }

    function merge(array, start, middle, end) {
        var left = [],
            right = [],
            leftSize = middle - start,
            rightSize = end - middle,
            maxSize = Math.max(leftSize, rightSize),
            size = end - start,
            i;

        for (i = 0; i < maxSize; i += 1) {
            if (i < leftSize) {
                left[i] = array[start + i];
            }
            if (i < rightSize) {
                right[i] = array[middle + i];
            }
        }
        i = 0;
        while (i < size) {
            if (left.length && right.length) {
                if (left[0] >= right[0]) {
                    array[start + i] = right.shift();
                } else {
                    array[start + i] = left.shift();
                }
            } else if (left.length) {
                array[start + i] = left.shift();
            } else {
                array[start + i] = right.shift();
            }
            i += 1;
        }
        return array;
    }
    return function (array) {
        return merger(array, 0, array.length);
    }

}());

mergeSort(array);
