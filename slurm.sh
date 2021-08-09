#!/bin/bash       
#SBATCH --job-name=gemini    
#SBATCH --nodes=8  
#SBATCH --ntasks-per-node=1
#SBATCH --error=slogs/%j.err    
#SBATCH --output=slogs/%j.out    

echo "process will start at : "
date
echo "++++++++++++++++++++++++++++++++++++++++"

# setting environment for intel2020u1
#source /opt/soft/oneapi/setvars.sh

#module unload mpi
#module load intel/oneapi/2021.2   
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so
export I_MPI_OFI_PROVIDER=sockets 

#mpirun -n 4 /home/yuang/Graph/Gemini-Patched/toolkits/pagerank  ~/data/bel/lj.bel 4847572  10  
srun -N 8  /home/yuang/Graph/Gemini-Patched/toolkits/pagerank  ~/data/bel/lj.bel 4847572  10  

echo "++++++++++++++++++++++++++++++++++++++++"
echo "process end at : "
date
rm -rf $SLOG/nodelist.$SLURM_JOB_ID


