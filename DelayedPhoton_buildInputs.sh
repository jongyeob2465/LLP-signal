#!/bin/bash
export TARBALLDIR=$PWD
for FILE in inputs/SMS-N2N3_mN-200_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz
do
    echo  $FILE
    PROCESS=$(echo ${FILE} | cut -d "/" -f 2 | sed 's/\_tarball.tar.xz//')
    echo ${PROCESS}
    export BASEDIR=${PWD}
    rm -r work${1}_${PROCESS}
    mkdir work${1}_${PROCESS}
    export SUBMIT_WORKDIR=${PWD}/work${1}_${PROCESS}
    year=${1}
    dirname_tmp=${PROCESS}
    dirname_tem=$(echo ${dirname_tmp} | cut -d "/" -f 2 | sed 's/\_el9_amd64_gcc11_CMSSW_13_2_9//')
    echo $dirname_tem
    dirname=$dirname_tem
    echo "Final Directory Name  :    " $dirname

    if [ "${year}" = "2016" ]; then
	cp ./pythiafragments/${dirname}.py inputs/.
    elif [ "${year}" = "2017" ]; then
	cp ./pythiafragments/${dirname}.py inputs/.
    elif [ "${year}" = "2018" ]; then
	cp ./pythiafragments/${dirname}.py inputs/.
	echo "HADRONIZER=${dirname}.py  " >> ./submit/inputs.sh
    elif [ "${year}" = "2022" ]; then
	cp ./pythiafragments/${dirname}_cff.py inputs/.
    elif [ "${year}" = "2022EE" ]; then
	cp ./pythiafragments/${dirname}_cff.py inputs/.
    elif [ "${year}" = "2023" ]; then
	cp ./pythiafragments/${dirname}_cff.py inputs/.
    elif [ "${year}" = "2023BPix" ]; then
	cp ./pythiafragments/${dirname}_cff.py inputs/.
    elif [ "${year}" = "2024" ]; then
	cp ./pythiafragments/${dirname}_cff.py inputs/.
	cat inputs/${dirname}_cff.py
    fi
   

#    sed -i "s/processname/${PROCESS}/"  inputs/${dirname}_cff.py
    sed -i "s/processname/${dirname}/"  inputs/${dirname}_cff.py

    echo "TARBALL=${PROCESS}_tarball.tar.xz" > ./submit/inputs.sh
    echo "HADRONIZER=${dirname}_cff.py  " >> ./submit/inputs.sh
    echo "PROCESS=${PROCESS}" >> ./submit/inputs.sh
    echo "dirname=${dirname}" >> ./submit/inputs.sh
    echo "USERNAME=${USER}" >> ./submit/inputs.sh    
    
    cat inputs/${dirname}_cff.py

    ls submit/

    if [ -z "$2" ]
    then
	echo "MERGE=0" >> ./submit/inputs.sh
	echo "You want to produce events for $1. Good luck!"
    else
	echo "MERGE=1" >> ./submit/inputs.sh
	echo "You want to merge the T2 files for $1? Ok."
    fi

    if [ "${year}" = "2016" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}.py ./submit/input/
	cp ${BASEDIR}/exec2016HIPM.sh $SUBMIT_WORKDIR
	cp ${BASEDIR}/exec2016post.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2017" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}.py ./submit/input/
	cp ${BASEDIR}/exec2017.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2018" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}.py ./submit/input/
	cp ${BASEDIR}/exec2018.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2022" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}_cff.py ./submit/input/
	cp ${BASEDIR}/exec2022.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2022EE" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}_cff.py ./submit/input/
	cp ${BASEDIR}/exec2022EE.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2023" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}_cff.py ./submit/input/
	cp ${BASEDIR}/exec2023.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2023BPix" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}_cff.py ./submit/input/
	cp ${BASEDIR}/exec2023BPix.sh $SUBMIT_WORKDIR
    elif [ "${year}" = "2024" ]; then
	mkdir -p ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${dirname}_cff.py ./submit/input/
	cp ${BASEDIR}/exec2024.sh $SUBMIT_WORKDIR
    fi

    
    #creating tarball
    echo "Tarring up submit..."
    tar -chzf submit.tgz submit 
    rm -r ${BASEDIR}/submit/input/*
    
    mv submit.tgz $SUBMIT_WORKDIR
    
    rm -rf submit/inputs.sh
    #does everything look okay?
    ls -lh $SUBMIT_WORKDIR

done
