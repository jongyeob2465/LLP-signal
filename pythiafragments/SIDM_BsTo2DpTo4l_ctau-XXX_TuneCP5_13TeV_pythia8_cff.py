import FWCore.ParameterSet.Config as cms
externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
                                     args = cms.vstring('XY-Hadronzer_Path/processname_ctau-3p75_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz'),
                                     nEvents = cms.untracked.uint32(5000),
                                     numberOfParameters = cms.uint32(1),
                                     outputFile = cms.string('cmsgrid_final.lhe'),
                                     scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
                                     )

# Link to cards:
# https://github.com/phylsix/genproductions/tree/master/bin/MadGraph5_aMCatNLO/cards/production/2017/13TeV/SIDM_LO/XXTo2ATo4Mu/SIDM_XXTo2ATo4Mu_mXX-500_mA-0p25


import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *

# Hadronizer configuration
generator = cms.EDFilter("Pythia8HadronizerFilter",
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    filterEfficiency = cms.untracked.double(1.0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    comEnergy = cms.double(13000.),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        processParameters = cms.vstring(
            'LesHouches:setLifetime = 2',
            'ParticleDecays:allowPhotonRadiation = on',
            'Zprime:vd=0.0',
            'Zprime:ad=0.0',
            'Zprime:vu=0.0',
            'Zprime:au=0.0',
            'Zprime:ve=X__CTAU__X',
            'Zprime:vnue=0.0',
            'Zprime:ae=0.0',
            'Zprime:anue=0.0',
        ),
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'pythia8PSweightsSettings',
                                    'processParameters',
                                    )
    )
)

genParticlesForFilter = cms.EDProducer(
    "GenParticleProducer",
    saveBarCodes=cms.untracked.bool(True),
    src=cms.InputTag("generator", "unsmeared"),
    abortOnUnknownPDGCode=cms.untracked.bool(False)
)

genfilter = cms.EDFilter(
    "GenParticleSelector",
    src = cms.InputTag("genParticlesForFilter"),
    cut = cms.string(' && '.join([
        '(abs(pdgId)==11 || abs(pdgId)==13)',
        'abs(eta)<2.4',
        '(vertex.rho<740. && abs(vertex.Z)<960.)',
        'pt>5.',
        'isLastCopy()',
        'isPromptFinalState()',
        'fromHardProcessFinalState()',
    ]))
)
gencount = cms.EDFilter(
    "CandViewCountFilter",
    src = cms.InputTag("genfilter"),
    minNumber = cms.uint32(4)
)

ProductionFilterSequence = cms.Sequence(
    generator * (genParticlesForFilter + genfilter + gencount)

)
