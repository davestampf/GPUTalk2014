#include <stdio.h>

__global__ void shift(int *xdata, int length) {
	__shared__ int data[1024];

	if (threadIdx.x >= length-1) return;
	data[threadIdx.x] = threadIdx.x;


	if (threadIdx.x > 0) {
		data[threadIdx.x-1] = data[threadIdx.x];
	}

	// copy to global so host can see it

	for (int i = 0; i < length; i++) {
		xdata[i] = data[i];
	}
}

int main() {
	int h_data[1024];
	for (int i = 0; i < 1024; i++) {
		h_data[i] = i;
	}

	void *d_data;

	cudaMalloc(&d_data,1024*sizeof(int));
	cudaMemcpy(d_data,h_data,1024*sizeof(int),cudaMemcpyHostToDevice);

	shift<<<1,1024>>>((int*) d_data,1024);

	cudaMemcpy(h_data,d_data,1024*sizeof(int),cudaMemcpyDeviceToHost);
	cudaFree(d_data);

	// lets make sure answer is correct

	for (int i = 0; i < 1023; i++) {
		if (h_data[i] != (i+1)) {
			printf("Differ at position %d value computed %d value expected %d\n",i,h_data[i],i+1);
		}
	}
}
