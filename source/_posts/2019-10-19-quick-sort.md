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
**lomuto 分组法**
选中第一为个 pivot，利用两个游标 i 和 j 把数组划分成
```
arr[pivot] | arr[(pivot+1)..(j)] | arr[(j + 1)..(i-1)] | arr[i..high]
pivot      | 比 pivot 小          | 比 pivot 大          | 未处理
在划分结束之后，交换 pivot 和 j
lomuto 分割法里面，pivot 的选取会决定数组的分组方式
```
```java
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
```

**hoare 分组法**
选中任意一个作为 pivot，利用两个游标 i 和 j，做数组的左右往里面扫描。i 扫过的区域一定要比 pivot 小，j 扫过的区域一定比 pivot 大。当遇到不满足条件的时候，交换 i, j 指向的内容。
```java
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
```
ps: 
- hoare 分组法会比 lomuto 分组法有平均少 3 倍的 swap 次数。[参考](https://ipfs-sec.stackexchange.cloudflare-ipfs.com/cs/A/question/11458.html)
- hoare 和 lomuto 都是不稳定的，并且在元素全部有序的情况下复杂度都是 O(n^2)
- [完整代码和测试用例](https://github.com/razertory/java-code-lab/blob/master/src/main/java/org/razertory/javacodelab/sort/QuickSort.java)
- 发明者 [Tony Hoare](https://zh.wikipedia.org/wiki/%E6%9D%B1%E5%B0%BC%C2%B7%E9%9C%8D%E7%88%BE)
