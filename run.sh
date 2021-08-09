TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG=./logs
EXP_NAME="exp"
EXP_NAME=${EXP_NAME}-${TIMESTAMP}
EXP_NAME="all_r_3"
O_DIR=${LOG}/${EXP_NAME}
mkdir -p ${O_DIR}

declare -A DATASET_SIZE

DATASET_SIZE=(["lj"]=4847572 ["wl"]=18268993 ["pld"]=42889800  ["tw"]=41652230 ["mpi"]=52579683 ["ur"]=67108864 ["kr"]=67108863)

PRD=prdelta
PR=pr
BFS=bfs
BC=bc
SSSP=sssp

#parameters
ROUND=3
ITER=20
PROC=8

declare -A root_ori
root_ori=( ["pld"]=5325333 ["kr"]=66805180 ["lj"]=327609 ["wl"]=14725342 ["tw"]=23934132 ["mpi"]=779958 ["ur"]=63436771 )


declare -A root_seq
root_seq=( ["pld"]=5247229 ["kr"]=66602775 ["lj"]=833553 ["wl"]=17309707 ["tw"]=23611176 ["mpi"]=141 ["ur"]=63311664 )

declare -A root_bi							

root_bi=( ["pld"]=638109 ["kr"]=5638255 ["lj"]=239578 ["wl"]=3418653 ["tw"]=2169363 ["mpi"]=144 ["ur"]=37669432 )

declare -A root_dbg							
root_dbg=( ["pld"]=20251 ["kr"]=312529 ["lj"]=1448 ["wl"]=47668 ["tw"]=110897 ["mpi"]=42 ["ur"]=61 )

declare -A root_fbc
root_fbc=( ["pld"]=0 ["kr"]=0 ["lj"]=0 ["wl"]=0 ["tw"]=0 ["mpi"]=0 ["ur"]=0 )

declare -A root_srt
root_srt=( ["pld"]=0 ["kr"]=0 ["lj"]=0 ["wl"]=0 ["tw"]=0 ["mpi"]=0 ["ur"]=0 )

declare -A root_rnd
root_rnd=( ["pld"]=13824444 ["kr"]=45423581 ["lj"]=147984 ["wl"]=4983168 ["tw"]=32274844 ["mpi"]=2738777 ["ur"]=41386542 )



for DATA in lj pld  wl tw mpi ur kr; do #lj  pld  wl tw mpi ur kr
    for APP in cc; do
        for POST in "_srt" "_rnd" "_seq" "_bi" "_fbc" "_dbg" "_srt" ; do #"_seq" "_bi" "_fbc" "_dbg" "_srt" "_rnd"
            echo "${APP}: data: ${DATA}${POST}, data size: ${DATASET_SIZE[${DATA}]}, process: ${PROC}, iterations: ${ITER}, ROUND: ${ROUND}"
            srun -N ${PROC}  ./toolkits/pagerank  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${DATA}]}  ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
        done 
    done
done


for RAW_DATA in lj  pld  wl tw mpi ur kr; do #lj  pld  wl tw mpi ur kr
    for APP in bfs bc ;  do #bfs cc bc sssp 
        if [ "$APP" = "sssp" ]; then
            DATA=${RAW_DATA}"_w"
        else
            DATA=${RAW_DATA}
        fi
        for POST in "_ori" "_dbg" "_srt" "_rnd" "_seq" "_bi" "_fbc"; do #"_ori" "_dbg" "_srt" "_rnd" "_seq" "_bi" "_fbc"
            echo "${APP}: data: ${DATA}${POST}, size: ${DATASET_SIZE[${RAW_DATA}]}, vertex: ${root_seq[${RAW_DATA}]}, round: ${ROUND}"
            if [ "$POST" = "_bi" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_bi[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_fbc" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_fbc[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_dbg" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_dbg[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_srt" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_srt[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_rnd" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_rnd[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_ori" ]; then
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_ori[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            elif [ "$POST" = "_seq" ]; then  
            srun -N ${PROC}  ./toolkits/${APP}  ~/data/bel/${DATA}${POST}.bel ${DATASET_SIZE[${RAW_DATA}]} ${root_seq[${RAW_DATA}]} ${ROUND} > ${O_DIR}/${APP}.${DATA}${POST}.log 2>&1
            else
                echo "what is this?" 
            fi
        done 
    done
done