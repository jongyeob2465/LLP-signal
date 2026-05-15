#!/bin/bash
###########
# setup
export BASEDIR=`pwd`
############# inputs
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source $VO_CMS_SW_DIR/cmsset_default.sh
source inputs.sh

############# make a working area

echo " Start to work now"
pwd
mkdir -p ./work
cd    ./work
export WORKDIR=`pwd`

############## generate LHEs

RANDOMSEED=`od -vAn -N4 -tu4 < /dev/urandom`
RANDOMSEED=`echo $RANDOMSEED | rev | cut -c 3- | rev` #Sometimes the RANDOMSEED is too long for madgraph

#Run
TempNumber=${RANDOMSEED}
outfilename_tmp="$PROCESS"'_'"$RANDOMSEED"
outfilename="${outfilename_tmp//[[:space:]]/}"


echo $PROCESS
echo $dirname

#
#############
#############
# Generate GEN-SIM
export SCRAM_ARCH=el9_amd64_gcc11
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_13_0_13/src ] ; then
 echo release CMSSW_13_0_13 already exists
else
scram p CMSSW CMSSW_13_0_13
fi
cd CMSSW_13_0_13/src
eval `scram runtime -sh`
mkdir -p Configuration/GenProduction/python/
cd Configuration/GenProduction/python/
cp ${BASEDIR}/input/${HADRONIZER} ./
echo  ${HADRONIZER}
echo ${TARBALL}
echo $PWD
cp ${BASEDIR}/input/${TARBALL} ./
sed -i "s@XY-Hadronzer_Path@$(pwd)@" ${HADRONIZER}
cd ../../../
scram b -j 8
cd ../../


cmsDriver.py Configuration/GenProduction/python/${HADRONIZER} --python_filename ${outfilename}_gensim.py  --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM,LHE --fileout file:${outfilename}_gensim.root --conditions 130X_mcRun3_2023_realistic_postBPix_v2 --beamspot Realistic25ns13p6TeVEarly2023Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(212)"\\nprocess.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${RANDOMSEED})" --step LHE,GEN,SIM --geometry DB:Extended --era Run3_2023 --no_exec --mc -n 50

cmsRun ${outfilename}_gensim.py



export SCRAM_ARCH=el8_amd64_gcc11
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_13_0_14/src ] ; then
  echo release CMSSW_13_0_14 already exists
else
  scram p CMSSW CMSSW_13_0_14
fi
cd CMSSW_13_0_14/src
eval `scram runtime -sh`
cd ../../

#PreMix
cmsDriver.py step1 --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 130X_mcRun3_2023_realistic_postBPix_v2 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2023v12 --procModifiers premix_stage2 --nThreads 4 --geometry DB:Extended --datamix PreMix --era Run3_2023  --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --filein file:${outfilename}_gensim.root --fileout file:${outfilename}_Premix.root --no_exec --python_filename ${outfilename}_Premix.py -n 9999

cmsRun ${outfilename}_Premix.py


#AOD   
cmsDriver.py step2 --python_filename ${outfilename}_reco_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:${outfilename}_RECO.root  --conditions 130X_mcRun3_2023_realistic_postBPix_v2 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:${outfilename}_Premix.root  --nThreads 4  --era Run3_2023 --no_exec --mc -n 9999

cmsRun ${outfilename}_reco_cfg.py



#MiniAOD 
cmsDriver.py step3 --python_filename ${outfilename}_miniaod_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:${outfilename}_miniaod.root --conditions 130X_mcRun3_2023_realistic_postBPix_v2 --step PAT --nThreads 2 --geometry DB:Extended --filein file:${outfilename}_RECO.root --era Run3_2023 --runUnscheduled --no_exec --mc -n 9999
#Run
cmsRun ${outfilename}_miniaod_cfg.py

###########
# Stage out #v1
echo "Copying the  MiniAOD  to FNAL storage"


#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/anTGC/Madgraph/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root     root://cmseos.fnal.gov//store/group/lpcmetx/SIDM/ULSignalSamples/RECOAOD/2023_v1/${dirname}_v4/MC_${dirname}_${TempNumber}_aod.root
xrdcp ${outfilename}_miniaod.root  root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2023BPix/MiniAOD/${dirname}_v2/MC_${dirname}_${TempNumber}_miniaod.root
xrdcp ${outfilename}_RECO.root     root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2023BPix/RECOAOD/${dirname}_v2/MC_${dirname}_${TempNumber}_aod.root
#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/EWKSignal/MiniAOD/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
echo "Copy  DONE."
