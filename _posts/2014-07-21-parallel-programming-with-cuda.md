---
layout: post
title: "Parallel Programming with CUDA"
modified: 2014-07-21 01:48:16 +0530
summary: Why use GPUs, and a "Hello World" example in CUDA/C. 
category: gpu
tags: gpu,CUDA
image:
  feature: 
  credit: 
  creditlink: 
comments: 
share: 
---

I recently started going through an amazing Udacity course on Parallel Programming. Having been working on image processing and computer vision for quite some time now, I have realized that CPUs are NOT designed for image processing applications. Even the oh-so-optimized OpenCV implementations of computer vision algorithms in C/C++ do not give a good speed when working on something as computationally expensive as variational optical flow. However, if you use the inbuilt CUDA module (in OpenCV 3.0), the performance is *way* better.

## Why GPUs?

CPUs are not getting any faster, due to limitation of clock speeds which have virtually remained the same since the past 5 years or so. Increasing this clock speed has become close to impossible, since increasing clock speeds increases the power consumption, which makes it difficult to cool the CPU. So, for faster computations, GPUs are the way to go.


## GPU vs CPU

My computer has a quad-core processor with hyper threading (an Intel i7 Ivy Bridge). This means that, in the best case, I can have at most 8-threads truly running in parallel. On the other hand, the low-end GPU that I have (nVidia GeForce GT630M) has 96 cores!

In general, a CPU has a few, very powerful computation cores, where as a GPU has a very large number of smaller, less powerful computation cores. The time taken to perform any one particular task is less on the CPU, but if you need to performs thousands of such tasks, then the GPU would beat the CPU.

One more important thing to note is that, while designing CPUs engineers optimize for *latency*. On the other hand, maximum *thorughput* is what the designers are aiming at while making GPUs.


## Throughput vs Latency

* Throughput: It is defined as the amount of work done in unit time. For example, I need to transport 50 bags of rice from ground floor of a building to the 10th floor, and I can carry at most two bags at a time. Let the time taken in each trip be 5 minutes. So, the amount of work done in one hour would be 2*(60/5) = 24 bags. I can say that the throughput is 24 bags/hr.

* Latency: It is defined as the amount of time taken to perform a particular task. In the previous example, it would take take 125 minutes to take all the 50 bags, and hence the latency (measures in time units) is 125 minutes.

## CUDA

CUDA is a framework developed by nVidia for writing programs that run both on the GPU and the CPU. On the CPU side, you can write programs in C, and then used some extensions to C (written by nVidia) to write programs that run on the GPU. These programs that run on the GPU are called *kernels*. A kernel looks like a serial program, but the CPU launches on a large  number of threads on the GPU. In CUDA, the CPU is referred to as the *host* while the GPU is referred to as the *device*. In this relationship between the CPU and the GPU, the CPU is the *alpha*. The CPU and the GPU have separate memories, and can perform operations only on the data that is stored in their own memory. The CPU can allocate memory on the GPU, copy data from the CPU memory to the GPU memory, launch kernels on hundreds of thread on the GPU, and copy back the results from the GPU memory. The GPU, on the other hand, can only respond to call of memory copy made by the CPU, and cannot make its own requests for data transfer.

#### Skeleton of a CUDA program:

* Allocate memory on the GPU
* Transfer data from the CPU memory to the GPU memory
* Perform the computations on the GPU
* Copy the results from the GPU to the CPU

A sample code in CUDA, which calculates the cubes of all integers from 1 to 64.


{% highlight C %}
#include <stdio.h>

// here is the kernel

__global__ void cube(float * d_out, float * d_in){
	// Todo: Fill in this function
    int idx = threadIdx.x;
    float f = d_in[idx];
    d_out[idx] = f*f*f;
}

// threadIdx is a C struct having members x,y,z, other structs available are blockIdx, threaddim, blockdim
//__global__ is what specifies that the fucntion is a kernel

int main(int argc, char ** argv) {
	const int ARRAY_SIZE = 64;
	const int ARRAY_BYTES = ARRAY_SIZE * sizeof(float);

	// generate the input array on the host
	float h_in[ARRAY_SIZE];
	for (int i = 0; i < ARRAY_SIZE; i++) {
		h_in[i] = float(i);
	}
	float h_out[ARRAY_SIZE];

	// declare GPU memory pointers
	float * d_in;
	float * d_out;

	// allocate GPU memory
	cudaMalloc((void**) &d_in, ARRAY_BYTES);
	cudaMalloc((void**) &d_out, ARRAY_BYTES);

	// transfer the array to the GPU
	cudaMemcpy(d_in, h_in, ARRAY_BYTES, cudaMemcpyHostToDevice);

	// launch the kernel
	cube<<<1, ARRAY_SIZE>>>(d_out, d_in);
	/*
	One block of 64 threads is being launched here. We specify the number of blocks as well as the number of threads in each block.
	Each block has a limited number of threads that it can support. Modern GPUs support 1024, older support 512.
	Can have any number of blocks. Cuda supports 2D and 3D arrangement of blocks as well.
	*/

	// copy back the result array to the CPU
	cudaMemcpy(h_out, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);

	// print out the resulting array
	for (int i =0; i < ARRAY_SIZE; i++) {
		printf("%f", h_out[i]);
		printf(((i % 4) != 3) ? "\t" : "\n");
	}

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}

{% endhighlight C %}

If you have the nVidia CUDA toolkit installed, you can compile and run the above program using:
{%highlight bash%}
nvcc -o sample sample.c
./sample
{%endhighlight bash%}






