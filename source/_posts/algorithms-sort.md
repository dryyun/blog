---
title: 排序算法
categories:
  - Algorithms
tags:
  - Algorithms
  - 算法
  - 快速排序
  - 归并排序
date: 2019-03-25 12:51:08
---
> Algorithms 分类文章，为了在下次又忘记又想想起来的时候，稍微快速的回想一下。

排序方法很多，仔细想想还是快排最实用  
冒泡排序、选择排序、桶排序、快速排序、归并排序、堆排序  

<!-- more --> 

# 冒泡排序

基本思路：从头开始，依次比较相邻的两个元素，把相对大(小)的值，交换给第二个元素，这样循环一次，最大(小)的元素就在最后，如此循环 n - 1次，就有结果。  

时间复杂度 O(N<sup>2</sup>)  

JavaScript 代码实现  
```javascript
// 冒泡排序，从小到大排序
function bubbleSort(arr) {
    let length = arr.length;
    for (let i = 0; i < length - 1; i++) {
        for (let j = 0; j < length - 1 - i; j++) {
            if (arr[j] > arr[j + 1]) { // 修改这判断，可以改成从大到小排序
                [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]]
            }
        }
    }
    return arr
}
```

# 选择排序

基本思路：第一个元素，依次跟后面的元素比较，把相对大(小)的值，交换给第一个元素，这样比较依次，最大(小)的元素就在开头，如此循环，比较第二(3,4,5,)个元素和后面的元素，循环 n-1 次就有结果。  

时间复杂度 O(N<sup>2</sup>)  

```javascript
// 选择排序，从小到大排序
function selectionSort(arr) {
    let length = arr.length;
    for (let i = 0; i < length - 1; i++) {
        for (let j = i + 1; j < length; j++) {
            if (arr[i] > arr[j]) { // 修改这判断，可以改成从大到小排序
                [arr[i], arr[j]] = [arr[j], arr[i]]
            }
        }
    }
    return arr;
}
```


# 桶排序
基本思想：找出最小、最大值，设定桶的数量，遍历数组，按照规则把一定范围内的元素加入特定的桶，每个桶也应用分别使用排序算法，循环桶的数量，得出结果。
一种特殊情况，桶的数量 = 最大-最小值 + 1

时间复杂度 O(n+k)

代码示例就是这种特殊情况
```javascript
function bucketSort(arr) {
    let max = arr[0], min = arr[0];
    for (let i = 0; i < arr.length; i++) {
        if (arr[i] < min) {
            min = arr[i]
        }
        if (arr[i] > max) {
            max = arr[i]
        }
    }
    let buckets = [];
    for (let i = 0; i < arr.length; i++) {
        if (!buckets[arr[i] - min]) {
            buckets[arr[i] - min] = []
        }
        buckets[arr[i] - min].push(arr[i])
    }

    let result = [];
    buckets.forEach((val, key) => {
        if (val.length) {
            result.push(...val)
        }
    });
    return result;
}
```


# 快速排序

基本思想：分而治之思想
选出一个元素作为基准值，可以选第一个元素。遍历所有的元素，比基准值大的都放在后面分区 greater，不比基准值小的都放在前面分区 less，在递归对着两个分区应用这个排序方法，递归最后得出结果。

时间复杂度 O(N log N)

```javascript
// 快速排序，从小到大排序
function quickSort(arr) {
    if (arr.length < 2) {
        return arr;
    }
    let pivot = arr[0];//基准值
    let less = arr.filter((v, k) => {
        return k !== 0 && v <= pivot;
    });
    let greater = arr.filter((v, k) => {
        return k !== 0 && v > pivot;
    });
    
    // return quickSort(greater).concat([pivot], quickSort(less)); // 从大到小排序
    return quickSort(less).concat([pivot], quickSort(greater));
}
```

# 归并排序

基本思想：分而治之思想
以中间元素为分界，划分两个区间，对这两个区间做归并操作，前提认为这两个区间已经各自排序了。
递归操作，在这个两个区间依次按照上面的操作，到最后每个区间就一个元素，肯定是算排序了。

时间复杂度 O(N log N)

```javascript
// 归并排序，从小到大排序
function mergeSort(arr) {
    if (arr.length < 2) {
        return arr;
    }
    let middle = Math.floor(arr.length / 2);
    return merge(mergeSort(arr.slice(0, middle)), mergeSort(arr.slice(middle)))
}

function merge(left, right) {
    let result = [];
    while (left.length && right.length) {
        if (left[0] < right[0]) { // 修改这判断，可以改成从大到小排序
            result.push(left.shift());
        } else {
            result.push(right.shift());
        }
    }
    while (left.length) {
        result.push(left.shift());
    }
    while (right.length) {
        result.push(right.shift());
    }
    return result
}
```


# 堆排序

基本思想：利用堆这个数据结构进行排序  
堆是特殊的完全二叉树  
- 小顶堆，每个节点的值都小于等于子树中每个节点值  
- 大顶堆，每个节点的值都大于等于子树中每个节点值  

关键是构建堆，比如大顶堆，那么第一个元素就是最大值，然后把第一个元素和最后一个交换，把前面的 n-1 个元素，再次构建最大堆，如此循环。  

通过数组构建堆，如果数组从 1 开始索引，数组中下标 i 的节点，左子节点 i * 2  ，右子节点 i * 2 +1 ，父节点 i /2   

时间复杂度 O(N log N)

```javascript
function buildMaxHeap(arr) {
    let len = arr.length;
    for (let i = Math.floor(len / 2); i >= 0; i--) {
        heapify(arr, len, i);
    }
}

function heapify(arr, len, i) {
    let left = 2 * i + 1,
        right = 2 * i + 2,
        largest = i;

    if (left < len && arr[left] > arr[largest]) {
        largest = left;
    }

    if (right < len && arr[right] > arr[largest]) {
        largest = right;
    }

    if (largest !== i) {
        [arr[i], arr[largest]] = [arr[largest], arr[i]];
        heapify(arr, largest);
    }
    return arr
}

function heapSort(arr) {
    let len = arr.length;
    buildMaxHeap(arr);

    for (let i = arr.length - 1; i > 0; i--) {
        [arr[0], arr[i]] = [arr[i], arr[0]];
        len--;
        heapify(arr, len, 0);
    }
    return arr;
}
```




