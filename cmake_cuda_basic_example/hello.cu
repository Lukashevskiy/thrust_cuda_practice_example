#include <iostream>
#include <random>
#include <algorithm>
#include <vector>
__global__ void test_kernel(int *p1, int *p2, int length) {
    for(int i = 0; i < length; ++i){
        p2[i] = p1[i] + p2[i];
    }
}

int main(){

    std::random_device rd;
    std::mt19937 gen{rd()}; 
    std::uniform_int_distribution distrib{1, 100000};

    std::vector v1, v2;
    v1.reserve(100000);
    v2.reserve(100000);
    std::generate(v1.begin(), v1.end(), [=]{ return distrib(gen); });
    std::generate(v2.begin(), v2.end(), [=]{ return distrib(gen); });
    
    int *d1, *d2;
    size_t s = v1.size() * sizeof(int);

    cudaMalloc(reinterpret_cast<void**>(&d1), s);
    cudaMalloc(reinterpret_cast<void**>(&d2), s);
    
    cudaMemcpy(d1, &v1[0], s, cudaMemcpyHostToDevice);
    cudaMemcpy(d2, &v2[0], s, cudaMemcpyHostToDevice);

    for(auto el: v1){
        std:: cout << el << " ";
    }
    std::cout << std::endl;

    for(auto el: v2){
        std:: cout << el << " ";
    }
    std::cout << std::endl;

    test_kernel<<<1, 1>>>(d1, d2, v1.size());

    cudaMemcpy(&v2[0], d2, s, cudaMemcpyDeviceToHost);

    for(auto el: v2){
        std:: cout << el << " ";
    }

    std::cout << std::endl;

    cudaFree(d1);
    cudaFree(d2);

    std::cout << "Hello, world!" << std::endl;
    
    return 0;
}