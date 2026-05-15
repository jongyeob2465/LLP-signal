# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a CMS (Compact Muon Solenoid) Monte Carlo generation pipeline for Long-Lived Particle (LLP) physics analyses at the LHC. It produces simulated signal samples through the full CMS simulation chain: LHE → GEN-SIM → Premix/Digi → RECO/AOD → EXO-NanoAOD.

Two primary signal models are used:
- **SMS-N2N3** (SUSY neutralino decaying to gravitino + photon, long-lived)
- **SIDM** (Self-Interacting Dark Matter: BsTo2DpTo4Mu scenarios)

## Environment Setup

CMSSW is required. Source from CVMFS before running any CMS commands:
```bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
```

For GEN-SIM jobs: `SCRAM_ARCH=el9_amd64_gcc11`, `CMSSW_14_0_18`
For EXO-NanoAOD jobs: `SCRAM_ARCH=el9_amd64_gcc13`, `CMSSW_16_0_0_pre1` (at `/u/user/cykim2465/work/LLP/CMSSW_16_0_0_pre1`)

Renew X509 proxy before submitting jobs (valid 8 days):
```bash
bash proxy.sh
```

## Key Workflows

### 1. Build inputs and prepare submit directory (GEN-SIM → AOD)
```bash
bash DelayedPhoton_buildInputs.sh <year>
# year options: 2016, 2017, 2018, 2022, 2022EE, 2023, 2023BPix, 2024
```
This copies the Pythia fragment (`pythiafragments/<process>_cff.py`) into `inputs/`, sets `submit/inputs.sh`, and creates `submit.tgz`.

### 2. Submit AOD production jobs to HTCondor

**Before submitting**, check the following:
- `ctau` parameter and decay width in `pythiafragments/SMS-N2N3_mN-200_cff.py`
- Output file name in `submit/runEventGeneration2024.sh` (decay width corresponding to ctau is written in `ctau.txt`)

Then rebuild the inputs:
```bash
bash DelayedPhoton_buildInputs.sh 2024
```

```bash
python3 submit_2024.py <workdir> <njobs>
# e.g. python3 submit_2024.py work2024_SMS-N2N3_mN-200_... 100
```
Jobs run `submit/runEventGeneration2024.sh`, which executes the GEN-SIM → Premix → RECO steps inside CMSSW_14_0_18. Output RECO files go to `/pnfs/knu.ac.kr/data/cms/store/user/jongyeob/Sample/RECO/`.

### 3. Submit EXO-NanoAOD production jobs
```bash
# First populate list_aod.txt with input RECO file paths
python submit_2024_nano.py
```
Jobs run `exec2024_nano.sh`, which calls `cmsRun Run3_2024_PAT_EXONANO_template.py` in CMSSW_16_0_0_pre1. Output NanoAOD goes to `/pnfs/knu.ac.kr/data/cms/store/user/jongyeob/Sample/NanoAOD/`.

### 4. Monitor HTCondor jobs
```bash
condor_q           # check job status
condor_q -better-analyze <jobid>  # diagnose held jobs
```
Log files are in `EXOAOD_log/` (for AOD jobs) and `EXONANOAOD_log/` (for NanoAOD jobs).

## Repository Structure

- `DelayedPhoton_buildInputs.sh` — prepares inputs and `submit.tgz` for a given year/era
- `exec2024.sh` — HTCondor executable for GEN-SIM→AOD jobs (unpacks submit.tgz, runs the generation script)
- `exec2024_nano.sh` — HTCondor executable for EXO-NanoAOD jobs (runs cmsRun directly on a RECO file)
- `submit_2024.py` / `submit_2024_nano.py` — generate and submit HTCondor JDL files
- `proxy.sh` — renews VOMS proxy certificate
- `submit/runEventGeneration2024.sh` — full GEN-SIM → Premix → RECO pipeline script (run inside condor job)
- `pythiafragments/` — Pythia8/CMSSW generator configuration fragments (`*_cff.py`) per signal model
- `inputs/` — gridpack tarballs (`*_tarball.tar.xz`), Pythia fragments, and MadGraph5 base (`mgbasedir/`)
- `EXOAOD_log/` / `EXONANOAOD_log/` — HTCondor job stdout/stderr/log files

## Pythia Fragment Conventions

Fragments in `pythiafragments/` use the `_cff.py` suffix for Run3 (2022+) and no suffix for earlier eras. The placeholder `processname` in fragments is replaced by `sed` in `DelayedPhoton_buildInputs.sh` with the actual process name. The gridpack path inside fragments must point to the actual tarball location on the worker node (passed via `inputs.sh`).

## Condor Job Configuration

Both submission scripts use:
- `x509userproxy = /pnfs/knu.ac.kr/data/cms/store/user/jongyeob/public/x509up`
- `+AccountingGroup = "analysis.jongyeob"`
- `+ProjectName = "CpDarkMatterSimulation"`
- KNU T2 cluster (`cluster142.knu.ac.kr`) for storage via XRootD

The `submit_2024.py` script takes `<workdir>` (path containing `exec2024.sh` and `submit.tgz`) and `<njobs>` as positional arguments. The nano version reads input files from `list_aod.txt` in the current directory.
