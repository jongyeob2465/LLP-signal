#!/bin/bash

export HOME=${PWD}
cd ${HOME}
echo "Starting job on " `date` #Date/time of start of job
echo "Running on: `uname -a`" #Condor job is running on this node
echo "System software: `cat /etc/redhat-release`" #Operating System on that node
echo "Arguments passed to the job, $1"

export SCRAM_ARCH=el9_amd64_gcc13
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
echo "$VO_CMS_SW_DIR $SCRAM_ARCH"
source $VO_CMS_SW_DIR/cmsset_default.sh

cd /u/user/cykim2465/work/LLP/CMSSW_16_0_0_pre1/src
eval `scramv1 runtime -sh` # cmsenv is an alias not on the workers
cd PhysicsTools/EXOnanoAOD/test/

export OUTPUT_NAME="exonano_$(basename $1 _RECO.root).root"
cmsRun Run3_2024_PAT_EXONANO_template.py  inputs=$1 outputs=${HOME}/${OUTPUT_NAME}

mv ${HOME}/${OUTPUT_NAME} /pnfs/knu.ac.kr/data/cms/store/user/jongyeob/Sample/NanoAOD/${OUTPUT_NAME}

#/eos/user/j/jongyeob/EXOMDS_2024NANOAOD/Jan_13/${OUTPUT_NAME} # backup command?
exit 0
