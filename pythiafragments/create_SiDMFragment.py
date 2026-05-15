#!/usr/bin/env python
from __future__ import print_function
import os
import math

# Define process and template
process = 'BsTo2DpTo4Mu'  # or 'BsTo2DpTo2Mu2e'
template = 'SIDM_BsTo2DpTo4l_ctau-XXX_TuneCP5_13TeV_pythia8_cff.py'
verbose = True  # Set to True for debugging

# List of parameters (mBs, mDp, cTau)
paramList = [
    (500, 5.0, 0.08),
    (500, 5.0, 0.8),
    (500, 5.0, 8.0),
    (500, 5.0, 40.0),
    (500, 5.0, 80.0),    

    (500, 0.25, 0.004),
    (500, 0.25, 0.04),
    (500, 0.25, 0.4),
    (500, 0.25, 2.0),
    (500, 0.25, 4.0),

]

# Main execution
if __name__ == '__main__':
    for mBs, mDp, cTau in paramList:
        # Format parameter strings
        mBs_str = str(mBs)
        mDp_str = str(mDp).replace('.', 'p')
        ctau_str = str(cTau).replace('.', 'p')
        
        # Generate fragment name
        #fragName = 'SIDM_BsTo2DpTo2Mu2e_MBs-{0}_MDp-{1}_ctau-{2}_v2.py'.format(mBs_str, mDp_str, ctau_str)
        #fragName = 'SIDM_BsTo2DpTo4Mu_MBs-{0}_MDp-{1}_ctau-{2}_v2.py'.format(mBs_str, mDp_str, ctau_str)
        fragName = 'SIDMRun3_CutDecayFalse_SIDM_BsTo2DpTo4Mu_MBs-{0}_MDp-{1}_ctau-{2}_v3.py'.format(mBs_str, mDp_str, ctau_str)
        
        # Skip if file already exists
        if os.path.isfile(fragName):
            continue
        
        # Copy template to new fragment name
        os.system('cp "{0}" "{1}"'.format(template, fragName))
        
        # Calculate lifetime
        #lifetime = math.sqrt(1 / (mDp * cTau)) * 1e-6
        lifetime = (math.sqrt(1 / (cTau)) * 1e-6)*0.375

        # Print calculated values
        print("mBs:", mBs, "mDp:", mDp, "cTau:", cTau, "lifetime:", lifetime)
        
        # Open the file and replace the placeholder in its contents
        with open(fragName, 'r') as file:
            file_data = file.read()

        # Replace the placeholder with the calculated lifetime
        file_data = file_data.replace('X__CTAU__X', str(lifetime))

        # Write the modified contents back to the file
        with open(fragName, 'w') as file:
            file.write(file_data)

        if verbose:
            print(f"Updated {fragName} with lifetime: {lifetime}")
