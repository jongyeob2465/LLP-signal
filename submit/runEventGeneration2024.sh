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

############# generate LHEs

RANDOMSEED=`od -vAn -N4 -tu4 < /dev/urandom`
RANDOMSEED=`echo $RANDOMSEED | rev | cut -c 3- | rev` #Sometimes the RANDOMSEED is too long for madgraph

#Run
TempNumber=${RANDOMSEED}
outfilename_tmp="$PROCESS"'_'"$RANDOMSEED"
outfilename="${outfilename_tmp//[[:space:]]/}"

echo $PROCESS
echo $dirname

#############
export SCRAM_ARCH=el9_amd64_gcc11
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_14_0_18/src ] ; then
 echo release CMSSW_14_0_18 already exists
else
scram p CMSSW CMSSW_14_0_18
fi
cd CMSSW_14_0_18/src
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

#cmsDriver.py Configuration/GenProduction/python/GEN-RunIII2024Summer24wmLHEGS-00030-fragment.py --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --beamspot DBrealistic --step LHE,GEN,SIM --geometry DB:Extended --conditions 140X_mcRun3_2024_realistic_v26 --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --datatier GEN-SIM,LHE --eventcontent RAWSIM,LHE --python_filename GEN-RunIII2024Summer24wmLHEGS-00030_1_cfg.py --fileout file:GEN-RunIII2024Summer24wmLHEGS-00030.root --number 100 --number_out 100 --no_exec --mc || exit $? ;

cmsDriver.py Configuration/GenProduction/python/${HADRONIZER} --python_filename ${outfilename}_gensim.py  --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:${outfilename}_gensim.root --conditions 140X_mcRun3_2024_realistic_v26 --beamspot DBrealistic --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(1000)"\\nprocess.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${RANDOMSEED})"\\nprocess.RandomNumberGeneratorService.generator.initialSeed="int(${RANDOMSEED})" --step GEN,SIM --geometry DB:Extended --era Run3_2024 --no_exec --mc -n 10

# Print generated config to log for RANDOMSEED verification
echo "=== ${outfilename}_gensim.py (RANDOMSEED=${RANDOMSEED}) ==="
cat ${outfilename}_gensim.py

#Run
cmsRun ${outfilename}_gensim.py

#PREMIX
#cmsDriver.py  --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions 140X_mcRun3_2024_realistic_v26 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2024v14 --procModifiers premix_stage2 --geometry DB:Extended --datamix PreMix --era Run3_2024 --python_filename GEN-RunIII2024Summer24DRPremix-00027_1_cfg.py --fileout file:GEN-RunIII2024Summer24DRPremix-00027_0.root --filein file:GEN-RunIII2024Summer24wmLHEGS-00030.root --number 100 --number_out 100 --pileup_input "dbs:/Neutrino_E-10_gun/RunIIISummer24PrePremix-Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/PREMIX" --no_exec --mc || exit $? ;

#cmsDriver.py step1 --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 140X_mcRun3_2024_realistic_v26 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2024v14 --procModifiers premix_stage2 --nThreads 4 --geometry DB:Extended --datamix PreMix --era Run3_2024  --pileup_input "dbs:/Neutrino_E-10_gun/RunIIISummer24PrePremix-Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/PREMIX" --filein file:${outfilename}_gensim.root --fileout file:${outfilename}_Premix.root --no_exec --python_filename ${outfilename}_Premix.py -n 9999

cmsDriver.py step1 --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 140X_mcRun3_2024_realistic_v26 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2024v14 --procModifiers premix_stage2 --nThreads 4 --geometry DB:Extended --datamix PreMix --era Run3_2024  --pileup_input "/store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520109/24346838-a050-4635-9223-b9c28b6471d5.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520110/34730391-4ee2-4128-8c28-6ac44b14adf1.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520110/4fbbdf7a-0f07-48b0-99e1-fbf80f824b6b.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520111/34b94eab-c72d-44c4-9060-5797136d3c93.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520111/4453678f-a51c-48a6-9579-ef2e247192f3.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520111/6b56f205-1116-473d-b8c0-2f8158baea07.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520111/c575b1de-2446-4824-8836-5ac6a9cbb2a3.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/0c0f461e-176f-4158-8c11-26972bb5f394.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/0ee31f2a-4121-42e9-bfe9-c3c7d872e7bc.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/1c7874b4-e284-4fea-9d93-9ecbbece3cb1.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/1f2cc00d-33dc-4bf6-a858-a387cb6d1596.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/246ce6ad-e249-4924-82c9-3a8932671fb5.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/293724e6-9f00-4dfe-b738-141f48d92738.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/3773a814-55d0-4082-b42b-22f2263049cf.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/391c919e-2ac9-4d8e-917e-627b4ca28bbf.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/4465c1d3-1654-4937-a158-3193cc22828e.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/5ee7aeb0-2730-438b-860e-feef46c43c3f.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/69cecbe4-ce10-4aad-ac94-f14e6c2f6749.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/6b52d495-a24b-4b4d-9174-f5c3f03b0f56.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/700cb757-22e5-401b-b22f-129b26a92a48.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/7e7e760e-d80c-4896-a34c-4ad12e6da0aa.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/7edd7c49-75a4-4ef6-aa99-4732d24d44e1.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/84c0ff4d-5ee6-48cb-a841-93f83017a103.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/8af1b45c-0614-42d6-9566-d66c01e11412.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/8ef6ac42-4976-47d6-b182-83531d736f14.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/9fa72c94-978a-4185-b655-47ba2b1f0504.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/a72b7636-2ef3-4a60-bde4-24703dc5b0e6.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/a910559a-eefb-4f20-a28a-eb7d52bff79e.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/ae6cce5d-2562-4e52-babc-93d644cb8857.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/afb8c8be-2169-4c2f-84b4-99db1fe18616.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/b3fc4b00-1a89-4635-ad20-d11244084bee.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/bc184901-30f6-4a62-81ca-36612ec4e009.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/c8d5f189-608e-4b48-aea0-2e5e18ea393d.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/cdd73419-e40b-49de-bda0-d27d76c2be27.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/d5cf4b62-c78e-46ed-8c68-fa98fc5d1251.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/da7d9019-8395-42b6-8bdb-44d0d30de254.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/e5d64738-9ecf-4f26-922d-208d14e5c052.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/eab92a80-7c8a-4c42-8ee2-f945cfe2587e.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/ed4f342c-ae22-4d03-8c94-31afb2f11eaf.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/ef108322-865d-4dd3-b676-d40b1fac3daa.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/fb0cc2f8-13f7-4efa-a04d-018878e0379a.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/fba0dba4-4129-4308-a669-9e707b20d1cb.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/fe1abf35-0d65-4997-96ca-a1959a749e03.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520112/ff36b74e-fa85-4338-bed5-e3cd6b8d0dcc.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/010e76d0-078f-4558-80c2-6dbf1432aa87.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/0848b8b8-2cfc-42ab-896c-fa08fa88c5fd.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/0cfec673-d928-4f66-aefa-edc2d9f8dac8.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/26d103fe-b415-437a-b4f1-9ebcf39b2161.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/2eb03bbd-0a86-47c8-ac98-bb3e714a1743.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/335df197-5ed5-4687-9c23-2df782c02229.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/4464dd8f-87d0-4b9f-9ab8-3dc2efa8b855.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/74014637-f4bf-48ce-a84f-380073242106.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/8f4b56c5-afbd-417b-9adb-5f65115f86ea.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/aa350586-a934-4f54-8457-93ec25fe06a3.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/aaeebffb-d770-429d-a7c6-0fba50d53281.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/d357651d-26cf-4b55-9046-c648fb1a4198.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/dd9f463e-c9de-40da-8c4b-70a3758582cf.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/e60acc93-298b-4487-806f-36589d5287b9.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520113/f4bfe08e-9bfe-4b79-9ffb-8d0fd4d40f08.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/06de0ad5-6083-4edc-8832-eaf7f7427ca7.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/23589823-d212-4865-bbb2-8dd694407dbf.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/31e617f4-06f3-4166-81a7-4c235e0c4f3a.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/408d5636-e68d-4b73-83e5-3591b0c4694c.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/4e338009-c757-4824-bc24-89e81ac406f2.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/5e00d652-1e86-413b-96e9-041dc208dac0.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/5fa036ed-95a7-4679-a0a5-841fe981f197.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/858b2398-4fea-4dba-8a19-0c14e5cc89ae.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/8fc63194-3675-4f49-8427-607e8da60dbe.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/a7b757e6-15bb-46df-a6e2-b930407140dc.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/a9094089-9a6e-447a-9ce4-b065a90b971a.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/b0fbb727-b514-4f24-bf70-b5135f183042.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/b60af3a5-c938-4f25-9842-00f318fd08e2.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/c324366a-7c8d-4037-91b6-288c4a610e7f.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/dbf52a1c-49e2-41ef-90a7-83aaae96ad08.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/dd24964e-ce2e-4b10-a36b-b1a745f66ec4.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/dfed92ef-4cf0-408b-9aaa-ee9f0c493291.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/e0aae21e-7c79-4062-a91a-1849f0a50bf0.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/e668b595-2500-4470-be84-f1192ced9bca.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520114/ed176cc9-a545-456c-9f34-c08ddabd0c8e.root, /store/mc/RunIIISummer24PrePremix/Neutrino_E-10_gun/PREMIX/Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/2520115/07576763-3897-4ea5-a778-e0fa62090f64.root" --filein file:${outfilename}_gensim.root --fileout file:${outfilename}_Premix.root --no_exec --python_filename ${outfilename}_Premix.py -n 9999

#Run
cmsRun ${outfilename}_Premix.py

# Generate RECOAOD 
#cmsDriver.py  --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions 140X_mcRun3_2024_realistic_v26 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --era Run3_2024 --python_filename GEN-RunIII2024Summer24DRPremix-00027_2_cfg.py --fileout file:GEN-RunIII2024Summer24DRPremix-00027.root --filein file:GEN-RunIII2024Summer24DRPremix-00027_0.root --number 100 --number_out 100 --no_exec --mc || exit $? ;

cmsDriver.py step2 --python_filename ${outfilename}_reco_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:${outfilename}_RECO.root  --conditions 140X_mcRun3_2024_realistic_v26 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:${outfilename}_Premix.root  --nThreads 4  --era Run3_2024 --customise_commands "process.AODSIMoutput.outputCommands.extend(['keep *_rpcRecHits_*_*','keep *_dt1DRecHits_*_*','keep *_csc2DRecHits_*_*'])"  --no_exec --mc -n 9999
# added --customise_commands "process.AODSIMoutput.outputCommands.extend(['keep rpcRecHits*','keep *_dt1DRecHits_','keep csc2DRecHits_*'])" command (2026/1/9)

cmsRun ${outfilename}_reco_cfg.py

##########
#MiniAOD 

#export SCRAM_ARCH=el8_amd64_gcc12
#source /cvmfs/cms.cern.ch/cmsset_default.sh
#if [ -r CMSSW_15_0_2/src ] ; then
#  echo release CMSSW_15_0_2 already exists
#else
#  scram p CMSSW CMSSW_15_0_2
#fi
#cd CMSSW_15_0_2/src
#eval `scram runtime -sh`
#scram b -j 8
#cd ../..

#cmsDriver.py  --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --step PAT --geometry DB:Extended --conditions 150X_mcRun3_2024_realistic_v2 --datatier MINIAODSIM --eventcontent MINIAODSIM1 --python_filename GEN-RunIII2024Summer24MiniAODv6-00031_1_cfg.py --fileout file:GEN-RunIII2024Summer24MiniAODv6-00031.root --filein "dbs:/DYto2Tau_Bin-MLL-800to1500_TuneCP5_13p6TeV_powheg-pythia8/RunIII2024Summer24DRPremix-140X_mcRun3_2024_realistic_v26-v2/AODSIM" --number 600 --number_out 600 --no_exec --mc || exit $? ;

#cmsDriver.py step3 --python_filename ${outfilename}_miniaod_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:${outfilename}_miniaod.root --conditions 150X_mcRun3_2024_realistic_v2 --step PAT --nThreads 2 --geometry DB:Extended --filein file:${outfilename}_RECO.root --era Run3_2024 --runUnscheduled --no_exec --mc -n 9999

#Run
#cmsRun ${outfilename}_miniaod_cfg.py

#########
#NanoAOD
##cmsDriver.py  --scenario pp --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --step NANO --conditions 150X_mcRun3_2024_realistic_v2 --datatier NANOAODSIM --eventcontent NANOEDMAODSIM1 --python_filename GEN-RunIII2024Summer24NanoAODv15-00031_1_cfg.py --fileout file:GEN-RunIII2024Summer24NanoAODv15-00031.root --filein "dbs:/DYto2Tau_Bin-MLL-800to1500_TuneCP5_13p6TeV_powheg-pythia8/RunIII2024Summer24MiniAODv6-150X_mcRun3_2024_realistic_v2-v1/MINIAODSIM" --number 2000 --number_out 2000 --no_exec --mc || exit $? ;

#cmsDriver.py  --scenario pp --era Run3_2024 --customise Configuration/DataProcessing/Utils.addMonitoring --step NANO --conditions 150X_mcRun3_2024_realistic_v2 --datatier NANOAODSIM --eventcontent NANOAODSIM1 --python_filename  ${outfilename}_nanoaod_cfg.py --fileout file:${outfilename}_nanoaod.root --filein file:${outfilename}_miniaod.root  --no_exec --mc -n 9999

#cmsRun ${outfilename}_nanoaod_cfg.py
###########
# Stage out #v1
echo "Copying the  MiniAOD  to FNAL storage"

#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/anTGC/Madgraph/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root     root://cmseos.fnal.gov//store/group/lpcmetx/SIDM/ULSignalSamples/RECOAOD/2024_v1/${dirname}/MC_${dirname}_${TempNumber}_aod.root
#xrdcp ${outfilename}_miniaod.root  root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2023/MiniAOD/${dirname}_v2/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root     root://cluster142.knu.ac.kr//store/user/sdogra/SIDM/2023/RECOAOD/${dirname}_v2/MC_${dirname}_${TempNumber}_aod.root
#xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/EWKSignal/MiniAOD/2018/${dirname}/MC_${dirname}_${TempNumber}_miniaod.root
#xrdcp ${outfilename}_RECO.root      root://eoscms.cern.ch//eos/cms/store/group/phys_heavyions/sdogra/2023/${dirname}_v2/MC_${dirname}_${TempNumber}_aod.root 
mv ${outfilename}_RECO.root /pnfs/knu.ac.kr/data/cms/store/user/jongyeob/Sample/RECO/ctau8000/exoAOD_ctau8000_n1_200_sMajoradded_${dirname}_${TempNumber}_RECO.root
#xrdcp ${outfilename}_RECO.root   root://eosuser.cern.ch//eos/user/j/jongyeob/EXOnanoAOD_${dirname}_${TempNumber}.root
#xrdcp ${outfilename}_.root   root://cluster142.knu.ac.kr//store/user/jongyeob/DelayedPhoton/MiniAOD/2022/${dirname}/MC_${dirname}_${TempNumber}_nanoaod.root
#3xrdcp ${outfilename}_nanoaod.root   root://cluster142.knu.ac.kr//store/user/jongyeob/DelayedPhoton/MiniAOD/2022/${dirname}/MC_${dirname}_${TempNumber}_nanoaod.root
echo "Copy  DONE."