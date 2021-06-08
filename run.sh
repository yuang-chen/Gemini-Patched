TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG=./logs
EXP_NAME="exp"
EXP_NAME=${EXP_NAME}-${TIMESTAMP}
O_DIR=${LOG}/${EXP_NAME}
mkdir -p ${O_DIR}

declare -A DATASET

DATASET=(["lj"]=4847572 ["wl"]=18268993 ["pld"]=42889800  ["tw"]=41652230 ["mpi"]=52579683 ["ur_half"]=67108863 ["kr_half"]=67108863)

# for key in ${!datasets[@]}; do
#     echo ${key} ${datasets[${key}]}
# done

# for DATA in lj wl pld tw mpi kr_half ur_half; do #ur_half kr_half pld lj wl tw mpi
#     for POST in "" "_seq" "_crd"; do 
#         echo "Gemini: data: ${DATA}${POST}"
#         #srun -N 8 ./toolkits/pagerank ~/data/${DATA}${POST}.bel ${DATASET[${DATA}]} 10 > ${O_DIR}/"PageRank".${DATA}${POST}.log 2>&1
#         mpirun -machinefile host -np 8 ./toolkits/pagerank ~/data/${DATA}${POST}.bel ${DATASET[${DATA}]} 10 > "./logs/mpirun/PR".${DATA}${POST}.log 2>&1
#     done
# done

# for DATA in lj wl pld tw mpi kr_half; do #ur_half kr_half pld lj wl tw mpi
#     #for POST in "" "_seq" "_crd"; do 
#         echo "Gemini: data: ${DATA}"
#         srun -N 8 ./toolkits/pagerank ~/data/${DATA}.bel ${DATASET[${DATA}]} 10 > "./logs/srun/PR".${DATA}.log 2>&1
#     #done
# done

for DATA in lj wl pld tw mpi kr_half ; do #ur_half lj wl pld tw mpi kr_half 
    echo "Gemini: data: ${DATA}"
    srun -N 4 --nodelist=./host  ./toolkits/pagerank  ~/data/${DATA}.bel ${DATASET[${DATA}]} > ${O_DIR}/"PR".${DATA}.log 2>&1
done