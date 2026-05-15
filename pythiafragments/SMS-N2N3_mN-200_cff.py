import FWCore.ParameterSet.Config as cms

from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

import math
import sys
#1000015     1.00000000E+05   # ~tau_1\n

baseSLHATable="""
BLOCK MASS  # Mass Spectrum\n
# PDG code           mass       particle\n
   1000001     1.00000000E+05   # ~d_L\n
   2000001     1.00000000E+05   # ~d_R\n
   1000002     1.00000000E+05   # ~u_L\n
   2000002     1.00000000E+05   # ~u_R\n
   1000003     1.00000000E+05   # ~s_L\n
   2000003     1.00000000E+05   # ~s_R\n
   1000004     1.00000000E+05   # ~c_L\n
   2000004     1.00000000E+05   # ~c_R\n
   1000005     1.00000000E+05   # ~b_1\n
   2000005     1.00000000E+05   # ~b_2\n
   1000006     1.00000000E+05   # ~t_1\n
   2000006     1.00000000E+05   # ~t_2\n
   1000011     1.00000000E+05   # ~e_L\n
   2000011     1.00000000E+05   # ~e_R\n
   1000012     1.00000000E+05   # ~nu_eL\n
   1000013     1.00000000E+05   # ~mu_L\n
   2000013     1.00000000E+05   # ~mu_R\n
   1000014     1.00000000E+05   # ~nu_muL\n
   1000015     1.00000000E+05   # ~tau_1\n
   2000015     1.00000000E+05   # ~tau_2\n
   1000016     1.00000000E+05   # ~nu_tauL\n
   1000021     1.00000000E+05   # ~g\n
   1000022     2.00000000E+02   # ~chi_10\n
   1000023     1.00000000E+05           # ~chi_20\n
   1000025     1.00000000E+05           # ~chi_30\n
   1000035     1.00000000E+05   # ~chi_40\n
   1000024     1.00000000E+05   # ~chi_1+\n
   1000037     1.00000000E+05   # ~chi_2+\n
   1000039     4.70000000E-09   # ~gravitino\n
\n
# DECAY TABLE\n
#         PDG            Width\n
DECAY   1000001     0.00000000E+00   # sdown_L decays\n
DECAY   2000001     0.00000000E+00   # sdown_R decays\n
DECAY   1000002     0.00000000E+00   # sup_L decays\n
DECAY   2000002     0.00000000E+00   # sup_R decays\n
DECAY   1000003     0.00000000E+00   # sstrange_L decays\n
DECAY   2000003     0.00000000E+00   # sstrange_R decays\n
DECAY   1000004     0.00000000E+00   # scharm_L decays\n
DECAY   2000004     0.00000000E+00   # scharm_R decays\n
DECAY   1000005     0.00000000E+00   # sbottom1 decays\n
DECAY   2000005     0.00000000E+00   # sbottom2 decays\n
DECAY   1000006     0.00000000E+00   # stop1 decays\n
DECAY   2000006     0.00000000E+00   # stop2 decays\n
DECAY   1000011     0.00000000E+00   # selectron_L decays\n
DECAY   2000011     0.00000000E+00   # selectron_R decays\n
DECAY   1000012     0.00000000E+00   # snu_elL decays\n
DECAY   1000013     0.00000000E+00   # smuon_L decays\n
DECAY   2000013     0.00000000E+00   # smuon_R decays\n
DECAY   1000014     0.00000000E+00   # snu_muL decays\n
DECAY   1000015     0.00000000E+00   # stau_1 decays\n
DECAY   2000015     0.00000000E+00   # stau_2 decays\n
DECAY   1000016     0.00000000E+00   # snu_tauL decays\n
DECAY   1000021     0.00000000E+00   # gluino decays\n
DECAY   1000022     2.46600000E-17  # neutralino1 decays\n
    0.00000000E+00   2    1000022   22  #dummy decay\n
    1.00000000E+00   2    1000039   22\n
DECAY   1000023     0.00000000E+00  # neutralino2 decays\n
DECAY   1000024     0.00000000E+00   # chargino1+ decays\n
DECAY   1000025     0.00000000E+00   # neutralino3 decays\n
DECAY   1000035     0.00000000E+00   # neutralino4 decays\n
DECAY   1000037     0.00000000E+00   # chargino2+ decays\n
"""

generator = cms.EDFilter("Pythia8GeneratorFilter",
    maxEventsToPrint = cms.untracked.int32(1),
    pythiaPylistVerbosity = cms.untracked.int32(1),
    filterEfficiency = cms.untracked.double(1.0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    comEnergy = cms.double(13600.),
    RandomizedParameters = cms.VPSet(),
)

model = "N1N1"
batch = 1

# weighted average of matching efficiencies for the full scan
# must equal the number entered in McM generator params
mcm_eff = 0.248

# Number of events: min(goalLumi*xsec, maxEvents) (always in thousands)
goalLumi = 400
minLumi = 1e-40 # Skip minimum lumi
minEvents, maxEvents = 20, 1000
diagStep, bandStep = 25, 50
midDM, maxDM = 87, 100
addDiag = [183, 167] # DeltaM for additional diagonal lines to be added

class gridBlock:
  def __init__(self, xmin, xmax, xstep, ystep):
    self.xmin = xmin
    self.xmax = xmax
    self.xstep = xstep
    self.ystep = ystep

scanBlocks = []
if (batch==1):
  scanBlocks.append(gridBlock(1000,  1001, 100, 100))
minDM = 0
ymin, ymed, ymax = 0, 0, 2500

def matchParams(mass):
  if mass < 649: return 62., 0.274
  elif mass < 699: return 64., 0.269
  elif mass < 749: return 64., 0.269
  elif mass < 799: return 66., 0.259
  elif mass < 849: return 66., 0.261
  elif mass < 899: return 68., 0.257
  elif mass < 949: return 68., 0.252
  elif mass < 999: return 70., 0.250
  elif mass < 1049: return 70., 0.248
  elif mass < 1099: return 70., 0.248
  elif mass < 1149: return 70., 0.249
  elif mass < 1199: return 70., 0.242
  elif mass < 1249: return 70., 0.239
  elif mass < 1299: return 70., 0.242
  elif mass < 1349: return 70., 0.241
  elif mass < 1399: return 70., 0.237
  elif mass < 1449: return 70., 0.239
  elif mass < 1499: return 70., 0.241
  elif mass < 1549: return 70., 0.235
  elif mass < 1599: return 70., 0.239
  elif mass < 1649: return 70., 0.239
  elif mass < 1699: return 70., 0.237
  elif mass < 1749: return 70., 0.241
  elif mass < 1799: return 70., 0.237
  elif mass < 1849: return 70., 0.237
  elif mass < 1899: return 70., 0.240
  elif mass < 1949: return 70., 0.241
  elif mass < 1999: return 70., 0.244
  elif mass < 2049: return 70., 0.246
  elif mass < 2099: return 70., 0.249
  elif mass < 2149: return 70., 0.246
  elif mass < 2199: return 70., 0.246
  elif mass < 2249: return 70., 0.251
  elif mass < 2299: return 70., 0.249
  elif mass < 2349: return 70., 0.257
  elif mass < 2399: return 70., 0.257
  elif mass < 2449: return 70., 0.261
  elif mass < 2499: return 70., 0.264
  elif mass < 2549: return 70., 0.266
  ### Just for testing
  else: return 70., 0.243

def xsec(mass):
  if mass < 300: return 319925471928717.38*math.pow(mass, -4.10396285974583*math.exp(mass*0.0001317804474363))
  else: return 4855957031250000*math.pow(mass, -4.71716128867804*math.exp(mass*6.175277146619076e-05))

# Number of events for mass point, in thousands
def events(mass):
  xs = xsec(mass)
  nev = min(goalLumi*xs, maxEvents*1000)
  if nev < xs*minLumi: nev = xs*minLumi
  nev = max(nev/1000, minEvents)
  return math.ceil(nev) # Rounds up

cols = []
Nevents = []
xmin, xmax = 9999, 0
for block in scanBlocks:
  Nbulk, Ndiag = 0, 0
  for mx in range(block.xmin, block.xmax, min(bandStep, diagStep)):
    if (batch==2 and mx==block.xmin): continue
    xmin = min(xmin, block.xmin)
    xmax = max(xmax, block.xmax)
    col = []
    my = 0
    begBand = min(max(ymed, mx-maxDM), mx-minDM)
    begDiag = min(max(ymed, mx-midDM), mx-minDM)
    # Adding bulk points
    if (mx-block.xmin)%block.xstep == 0 :
      for my in range(ymin, begBand, block.ystep):
        if my > ymax: continue
        # Adding extra diagonals to the bulk
        nev = events(mx)
        col.append([mx,my, nev])
        Nbulk += nev
    
    cols.append(col)

  Nevents.append([Nbulk, Ndiag])

mpoints = []
for col in cols: mpoints.extend(col)

mstop, mlsp = 1000, 300
qcut, tru_eff = matchParams(mstop)
wgt = 20.0
print(mstop, mlsp, wgt)

if mlsp==0: mlsp = 1
slhatable = baseSLHATable.replace('%MSTOP%','%e' % mstop)
slhatable = slhatable.replace('%MLSP%','%e' % mlsp)
################################################

basePythiaParameters = cms.PSet(
    pythia8CP5SettingsBlock,
    pythia8PSweightsSettingsBlock,

    processParameters = cms.vstring(
        # --- Jet matching (MLM-like) ---
        'JetMatching:setMad = off',
        'JetMatching:scheme = 1',
        'JetMatching:merge = on',
        'JetMatching:jetAlgorithm = 2',
        'JetMatching:etaJetMax = 5.',
        'JetMatching:coneRadius = 1.',
        'JetMatching:slowJetPower = 1',
        'JetMatching:qCut = 76.',
        'JetMatching:nQmatch = 5',
        'JetMatching:nJetMax = 2',
        'JetMatching:doShowerKt = off',

        # --- Particle masses ---
        '6:m0 = 172.5',

        # --- Higgs decay control (force H->bb) ---
        '25:onMode = off',
        '25:onIfMatch = 5 -5',
        '25:doForceWidth = true',
        '25:mWidth = 2.0',
        '25:mMin = 30.0',
        '25:m0 = 125.0',

        # --- Safety / veto behavior ---
        'Check:abortIfVeto = on',
    ),

    pythia8CommonSettings = cms.vstring(
        'Tune:preferLHAPDF = 2',
        'Main:timesAllowErrors = 10000',
        'Check:epTolErr = 0.01',

        'Beams:setProductionScalesFromLHEF = off',
        'SLHA:minMassSM = 1000.',

        'ParticleDecays:limitTau0 = on',
        # NOTE: you had tau0Max twice; keep the larger one only to avoid confusion
        'ParticleDecays:tau0Max = 8000.1',
        'ParticleDecays:allowPhotonRadiation = on',

        # long-lived particle example (as given)
        '1000022:tau0 = 8000',
        'LesHouches:setLifetime = 2',

        # R-hadrons (kept as in your snippet)
        'RHadrons:allow = on',
    ),

    parameterSets = cms.vstring(
        'pythia8CommonSettings',
        'pythia8CP5Settings',
        'pythia8PSweightsSettings',
        'processParameters',
    )
)

generator.RandomizedParameters.append(
    cms.PSet(
        ConfigWeight = cms.double(wgt),
        GridpackPath =  cms.string('/u/user/cykim2465/work/LLP/test/inputs/SMS-N2N3_mN-200_el9_amd64_gcc11_CMSSW_13_2_9_tarball.tar.xz'),
        ConfigDescription = cms.string('%s_%i_%i' % (model, mstop, mlsp)),
        SLHATableForPythia8 = cms.string('%s' % slhatable),
        PythiaParameters = basePythiaParameters,
    ),
)
ProductionFilterSequence = cms.Sequence(generator)
