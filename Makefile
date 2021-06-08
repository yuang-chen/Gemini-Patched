ROOT_DIR= $(shell pwd)
TARGETS= toolkits/pagerank #toolkits/bc toolkits/bfs toolkits/cc toolkits/sssp
MACROS= 

MPICXX= mpiicpc
ICPCCFG= -O3 -Wall -std=c++11 -g -fopenmp -march=native -I$(ROOT_DIR) $(MACROS)
SYSLIBS= -lnuma
HEADERS= $(shell find . -name '*.hpp')

all: $(TARGETS)

toolkits/%: toolkits/%.cpp $(HEADERS)
	$(MPICXX) $(ICPCCFG) -o $@ $< $(SYSLIBS)

clean: 
	rm -f $(TARGETS)