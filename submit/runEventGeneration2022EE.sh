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
export SCRAM_ARCH=el8_amd64_gcc10
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_20/src ] ; then
 echo release CMSSW_12_4_20 already exists
else
scram p CMSSW CMSSW_12_4_20
fi
cd CMSSW_12_4_20/src
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


cmsDriver.py Configuration/GenProduction/python/${HADRONIZER} --python_filename ${outfilename}_gensim.py  --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM,LHE --fileout file:${outfilename}_gensim.root --conditions 124X_mcRun3_2022_realistic_postEE_v1 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(212)"\\nprocess.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${RANDOMSEED})" --step LHE,GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n 500

cmsRun ${outfilename}_gensim.py


export SCRAM_ARCH=el8_amd64_gcc10
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_16/src ] ; then
 echo release CMSSW_12_4_16 already exists
else
scram p CMSSW CMSSW_12_4_16
fi
cd CMSSW_12_4_16/src
eval `scram runtime -sh`
cd ../../
#Run


cmsDriver.py step1 --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v14 --procModifiers premix_stage2,siPixelQualityRawToDigi --nThreads 4 --geometry DB:Extended --datamix PreMix --era Run3  --pileup_input "/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40008/f0b6cae6-2636-4a33-b4f0-867c1e23e9b4.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/00bb36ac-9b33-4851-a858-264291295637.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/048cd96a-ca2b-438f-9313-32461b81038c.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/3251ffde-b144-4e3d-a6b9-61c9cc3ab4f9.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/3494c53e-d457-4a9c-80c7-d594f73e6310.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/44437a66-0524-4927-a8d9-b5ef269debaf.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/4b75b668-3b8c-44fc-802e-910ce406679f.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/53a83b84-38b7-4d91-b121-57488168704e.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/5b138d34-8dc5-48a9-b90f-8322ebaee741.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/8472762f-1c45-4460-86c6-45ed6fc71d96.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/86a2dd49-3a96-4c7e-a5cb-1de940576b8b.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/888572a5-3b16-4f98-999e-a88d5940654d.root,/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer22_124X_mcRun3_2022_realistic_v11-v2/40009/8d3d6249-fedf-4a62-a943-db2e02583824.root" --filein file:${outfilename}_gensim.root --fileout file:${outfilename}_Premix.root --no_exec --python_filename ${outfilename}_Premix.py -n 9999


#cmsDriver.py  --python_filename B2G-Run3Summer22EEDRPremix-04760_1_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:B2G-Run3Summer22EEDRPremix-04760_0.root --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v14 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended --filein file:B2G-Run3Summer22EEwmLHEGS-06241.root --datamix PreMix --era Run3 --no_exec --mc -n 9999



#Run
cmsRun ${outfilename}_Premix.py


# Generate RECOAOD
cmsDriver.py step2 --python_filename ${outfilename}_reco_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:${outfilename}_RECO.root  --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:${outfilename}_Premix.root --procModifiers siPixelQualityRawToDigi --nThreads 4  --era Run3 --no_exec --mc -n 9999

cmsRun ${outfilename}_reco_cfg.py


export SCRAM_ARCH=el8_amd64_gcc11
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_13_0_13/src ] ; then
  echo release CMSSW_13_0_13 already exists
else
  scram p CMSSW CMSSW_13_0_13
fi
cd CMSSW_13_0_13/src
eval `scram runtime -sh`
cd ../..
##########
#MiniAOD 
cmsDriver.py step3 --python_filename ${outfilename}_miniaod_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:${outfilename}_miniaod.root --conditions 130X_mcRun3_2022_realistic_postEE_v6 --step PAT --nThreads 2 --geometry DB:Extended --filein file:${outfilename}_RECO.root --era Run3 --runUnscheduled --no_exec --mc -n 9999



#Run
cmsRun ${outfilename}_miniaod_cfg.py

###########
# Stage out #v1
echo "Copying the  MiniAOD  to FNAL storage"

#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/anTGC/Madgraph/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root     root://cmseos.fnal.gov//store/group/lpcmetx/SIDM/ULSignalSamples/RECOAOD/2022_v1/${dirname}_v4/MC_${dirname}_${TempNumber}_aod.root
#xrdcp ${outfilename}_miniaod.root  root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2022/MiniAOD/${dirname}_v1/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root     root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2022/RECOAOD/${dirname}_v1/MC_${dirname}_${TempNumber}_aod.root
#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/EWKSignal/MiniAOD/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root

xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/WZAToLNuLLA/MiniAOD/2022EE/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
echo "Copy  DONE."
