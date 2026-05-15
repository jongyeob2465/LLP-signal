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
if [ -r CMSSW_10_6_29/src ] ; then
 echo release CMSSW_10_6_29 already exists
else
scram p CMSSW CMSSW_10_6_29
fi
cd CMSSW_10_6_29/src

echo "CMSENV"
eval `scramv1 runtime -sh`
export TOPDIR=$PWD

git config --global user.name 'Sunil Dogra'
git config --global user.email 'smdogra@gmail.com'
git config --global user.github smdogra

git-cms-init
# merge changes necessary for custom nanoaod production    
git clone git@github.com:kerstinlovisa/LLPNanoAOD.git


git cms-addpkg RecoVertex/KalmanVertexFit
git cms-addpkg RecoVertex/VertexTools
git cms-addpkg RecoVertex/KinematicFitPrimitives
git cms-addpkg PhysicsTools/RecoUtils

cp LLPNanoAOD/RecoVertex_corrections/VertexTools/src/* RecoVertex/VertexTools/src/
cp LLPNanoAOD/RecoVertex_corrections/VertexTools/interface/* RecoVertex/VertexTools/interface/
cp LLPNanoAOD/RecoVertex_corrections/KalmanVertexFit/src/* RecoVertex/KalmanVertexFit/src/
cp LLPNanoAOD/RecoVertex_corrections/KinematicFitPrimitives/src/* RecoVertex/KinematicFitPrimitives/src/
cp LLPNanoAOD/PhysicsTools_corrections/RecoUtils/src/* PhysicsTools/RecoUtils/src/
cp LLPNanoAOD/PhysicsTools_corrections/RecoUtils/interface/* PhysicsTools/RecoUtils/interface/

scram b -j 10
cp ${BASEDIR}/input/* .

cmsRun MC_2017_NANOAODv9_cfg.py

xrdcp ${PROCESS}.root   root://cluster142.knu.ac.kr//store/user/sdogra/VectorTop/NanoAOD/2017/${dirname}/MC_${PROCESS}.root
