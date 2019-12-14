---
title: 快速排序
date: 2019-10-19 16:52:23
tags: 
---
首先挑选基准值；然后分割数组，把小于基准值的元素放到基准值前面，大于基准值的元素放到基准值后面；最后递归地对小于基准值的子序列和大于基准值的子序列进行排序。如果用函数定义快速排序 f()，那么首先给这个函数签名为 f(arr, low, high)。其中，arr 表示传入的数组对象，low 表示需要排序的开始下标，high 表示需要排序的结束下标，那么这个函数可以完整地表示为。

``` python
f(arr, low, high) = 
  if low < high
    pivot = partition(arr, low, high)
    f(arr, low, pivot - 1)
    f(arr, pivot + 1, high)
```
总结起来就是，选基，分组，递归。分组函数 partition(arr, low, high) 的作用是把小于基准值的放在前面，大于基准值的放在后面，最后输出分组之后基准值所在的位置。做分组最经典的做法是用 lomuto 或者 hoare 分组法。
```java
// lomuto 分组法
int partition(int[] array, int low, int high) {
    int pivot = array[low], index = low;
    for (int i = low; i <= high; i++) {
        if (array[i] < pivot) {
            index++;
            swap(array, i, index);
        }
    }
    swap(array, index, low);
    return index;
}

// hoare 分组法
int partition(int[] array, int low, int high) {
    int p = array[low];
    int i = low, j = high;
    while(i < j) {
        while (i < j && array[j] > p) j--;
        if(i < j) swap(array, i, j);
        while (i < j && array[i] <= p) i++;
        if(i < j) swap(array, i, j);
    }
    return i;
}

// 交换数组中的元素
private void swap(int[] array, int i, int j) {
    int temp = array[i];
    array[i] = array[j];
    array[j] = temp;
}
```

这两者的比较如下
1. hoare 分组法会比 lomuto 分组法有平均少 3 倍的 swap 次数。[参考](https://ipfs-sec.stackexchange.cloudflare-ipfs.com/cs/A/question/11458.html)
2. hoare 和 lomuto 都是不稳定的，并且在元素全部有序的情况下复杂度都是 O(n^2)


