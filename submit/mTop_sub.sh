#!/usr/bin/env bash
export HOME=$PWD
echo "SOURCE CMSSW"
source inputs.sh
source /cvmfs/cms.cern.ch/cmsset_default.sh
pwd
ls
export BASEDIR=`pwd`
############## generate LHEs 
RANDOMSEED=`od -vAn -N4 -tu4 < /dev/urandom`
RANDOMSEED=`echo $RANDOMSEED | rev | cut -c 3- | rev` #Sometimes the RANDOMSEED is too long for madgraph                      

export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_26/src ] ; then
 echo release CMSSW_10_6_26 already exists
else
scram p CMSSW CMSSW_10_6_26
fi
cd CMSSW_10_6_26/src

echo "CMSENV"
eval `scramv1 runtime -sh`
export TOPDIR=$PWD

git config --global user.name 'Sunil Dogra'
git config --global user.email 'smdogra@gmail.com'
git config --global user.github smdogra

git-cms-init
# merge changes necessary for custom nanoaod production    
git-cms-merge-topic michaelwassmer:CMSSW_10_6_26_CustomNanoAODMonotop
# get jetToolbox for jet reclustering 
git clone https://github.com/cms-jet/JetToolbox JMEAnalysis/JetToolbox -b jetToolbox_102X_v3
# module to put PF candidates into NanoAOD 
git clone https://github.com/michaelwassmer/PFNano.git PhysicsTools/NanoMET
mkdir CustomNanoProd
cd CustomNanoProd
# get cmsDriver commands and configs 
git clone https://github.com/michaelwassmer/CustomNanoProd
cd $CMSSW_BASE/src
scram b -j 8
cp ${BASEDIR}/input/* .

cmsRun MC_2017_NANOAODv9_cfg.py

xrdcp ${PROCESS}.root   root://cluster142.knu.ac.kr//store/user/sdogra/VectorTop/NanoAOD/2017/${dirname}/MC_${PROCESS}.root
