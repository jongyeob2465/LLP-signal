#!/bin/bash
# submit_ctau_all.sh
# ctau 2000, 4000, 6000, 7000, 8000 각 10만 이벤트 submit 스크립트
# 각 ctau에 이미 생성된 파일 수를 고려하여 나머지 jobs만 submit
# 사용법: bash submit_ctau_all.sh [ctau값] (생략 시 전체 실행)
# 예: bash submit_ctau_all.sh 2000
#     bash submit_ctau_all.sh all

set -e

BASEDIR=/u/user/cykim2465/work/LLP/test
FRAGMENT="${BASEDIR}/pythiafragments/SMS-N2N3_mN-200_cff.py"
GENSIM="${BASEDIR}/submit/runEventGeneration2024.sh"
RECO_BASE="/pnfs/knu.ac.kr/data/cms/store/user/jongyeob/Sample/RECO"
WORKDIR_BASE="work2024_SMS-N2N3_mN-200"
BUILD_TMPDIR="work2024_SMS-N2N3_mN-200_el9_amd64_gcc11_CMSSW_13_2_9"

# ctau별 설정: tau0(mm), tau0Max, DECAY_WIDTH(GeV), 추가 njobs
declare -A TAU0=(
    [2000]=2000   [4000]=4000   [6000]=6000   [7000]=7000   [8000]=8000
)
declare -A TAU0MAX=(
    [2000]=2000.1 [4000]=4000.1 [6000]=6000.1 [7000]=7000.1 [8000]=8000.1
)
declare -A DECAY_WIDTH=(
    [2000]="9.86500000E-17"
    [4000]="4.93300000E-17"
    [6000]="3.28800000E-17"
    [7000]="2.81900000E-17"
    [8000]="2.46600000E-17"
)
# 10만개 기준 추가 필요 jobs (이미 생성된 것 제외)
declare -A NJOBS=(
    [2000]=9185
    [4000]=8717
    [6000]=8034
    [7000]=7993
    [8000]=8001
)

submit_ctau() {
    local CTAU=$1
    echo ""
    echo "============================================"
    echo "  Processing ctau${CTAU}"
    echo "  tau0=${TAU0[$CTAU]} mm, Gamma=${DECAY_WIDTH[$CTAU]} GeV"
    echo "  Submit ${NJOBS[$CTAU]} jobs"
    echo "============================================"

    cd "${BASEDIR}"

    # 1. fragment 수정
    sed -i "s/DECAY   1000022     [0-9.E+-]*  # neutralino1 decays/DECAY   1000022     ${DECAY_WIDTH[$CTAU]}  # neutralino1 decays/" "${FRAGMENT}"
    sed -i "s/'ParticleDecays:tau0Max = [0-9.]*',/'ParticleDecays:tau0Max = ${TAU0MAX[$CTAU]}',/" "${FRAGMENT}"
    sed -i "s/'1000022:tau0 = [0-9]*',/'1000022:tau0 = ${TAU0[$CTAU]}',/" "${FRAGMENT}"

    echo "[1/4] Fragment updated: tau0=${TAU0[$CTAU]}, tau0Max=${TAU0MAX[$CTAU]}, Gamma=${DECAY_WIDTH[$CTAU]}"

    # 2. runEventGeneration2024.sh 출력 경로 수정
    sed -i "s|mv \${outfilename}_RECO.root .*|mv \${outfilename}_RECO.root ${RECO_BASE}/ctau${CTAU}/exoAOD_ctau${CTAU}_n1_200_sMajoradded_\${dirname}_\${TempNumber}_RECO.root|" "${GENSIM}"

    echo "[2/4] Output path updated: ${RECO_BASE}/ctau${CTAU}/"

    # 3. buildInputs 실행 (workdir 생성)
    echo "[3/4] Running DelayedPhoton_buildInputs.sh 2024 ..."
    bash DelayedPhoton_buildInputs.sh 2024

    # 4. workdir rename
    if [ -d "${BUILD_TMPDIR}" ]; then
        TARGET_WORKDIR="${WORKDIR_BASE}_ctau${CTAU}"
        # 기존 ctau workdir이 있으면 백업
        if [ -d "${TARGET_WORKDIR}" ]; then
            rm -rf "${TARGET_WORKDIR}.bak"
            mv "${TARGET_WORKDIR}" "${TARGET_WORKDIR}.bak"
            echo "    기존 ${TARGET_WORKDIR} → ${TARGET_WORKDIR}.bak 로 백업"
        fi
        mv "${BUILD_TMPDIR}" "${TARGET_WORKDIR}"
        echo "    Renamed: ${BUILD_TMPDIR} → ${TARGET_WORKDIR}"
    else
        echo "ERROR: ${BUILD_TMPDIR} 디렉토리가 없습니다!"
        exit 1
    fi

    # 5. condor submit
    echo "[4/4] Submitting ${NJOBS[$CTAU]} jobs..."
    python3 submit_2024.py "${TARGET_WORKDIR}" "${NJOBS[$CTAU]}"
    echo "  ctau${CTAU} submit 완료!"
}

# 인수 처리
TARGET=${1:-all}

if [ "$TARGET" = "all" ]; then
    for CTAU in 2000 4000 6000 7000 8000; do
        submit_ctau $CTAU
    done
else
    case "$TARGET" in
        2000|4000|6000|7000|8000)
            submit_ctau $TARGET
            ;;
        *)
            echo "사용법: bash submit_ctau_all.sh [2000|4000|6000|7000|8000|all]"
            exit 1
            ;;
    esac
fi

echo ""
echo "=== 전체 submit 완료 ==="
echo "로그 파일: ${BASEDIR}/EXOAOD_log/"
echo "condor 상태 확인: condor_q"
