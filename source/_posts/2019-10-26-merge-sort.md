---
title: 归并排序
date: 2019-10-26 11:36:12
tags: [algo]
---

归并排序最核心的思想就是 merge 两个有序的数组。假设两个只有一个元素的数组合并，比如 `[34]`, `[33]`，合并之后就是 `[33, 34]`。假设这个数组要和 `[1, 100]` 合并，合并之后就是 `[1, 33, 34, 100]`。

可以看出当大小为 n 的有序数组和大小为 m 的有序数组合并之后大小就是 n + m。所以最重要的就是写出高效的合并算法，假设函数的签名是 

```java
// a， b 需要合并的数组
// temp 用来存放合并后的数组
void merge (int[] a, int[] b, int[] temp) 
```

其中 a，b 可以用同一个数组中的 low，mid，high 三组下标表示，这样做的原因是为了尽量减少内存开销。

```java
// arr 原数组
// low, mid, high 分割成两个需要 merge 的子数组
void merge (int[] arr, int low, int mid, int high, int[] temp)  {
    int i = low, j = mid + 1, k = 0;
    while (i <= mid && j <= high) {
      if (arr[i] <= arr[j]) tmp[k++] = arr[i++];
      else tmp[k++] = arr[j++];
    }
    while (i <= mid) tmp[k++] = arr[i++];
    while (j <= high) tmp[k++] = arr[j++];
    System.arraycopy(tmp, 0, arr, low, k);
}
```
在 merge 函数已经完成的情况下，接下来就需要把原来的数组进行递归地拆分然后 merge。

```java
void mergeSort(int[] arr, int low, int high, int[] tmp) {
   if (low < high) {
     int mid = low + (high - low) / 2;
     mergeSort(arr, low, mid, tmp);
     mergeSort(arr, mid + 1, high, tmp);
     merge(arr, low, mid, high, tmp);
   }
}
```
