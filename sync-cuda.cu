/*
 * compute 0 + 1 + 2 + ... + 1023 using cuda - in a bad way
 */

#include <stdlib.h>
#include <stdio.h>

__global__ void sum(int *result) {
	//*result = *result + threadIdx.x;
	atomicAdd(result,threadIdx.x);
}

int main() {

	int h_result = 0;
	void *d_result;

	cudaMalloc(&d_result,sizeof(int));
	cudaMemcpy(d_result,&h_result,sizeof(int),cudaMemcpyHostToDevice);
	
	sum<<<1,1024>>>((int*) d_result);

	cudaMemcpy(&h_result,d_result,sizeof(int),cudaMemcpyDeviceToHost);
	cudaFree(d_result);

	printf("We computed %d - should have been %d\n",h_result,1024*1023/2);
}

