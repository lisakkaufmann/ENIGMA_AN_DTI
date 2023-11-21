#!/bin/bash

# Set the paths to your input data folder and the output BIDS directory
input_data_folder="/Users/Lisa-Katrin/Documents/GitHub/ENIGMA_AN_DTI/Reshaping/Data/tensor_maps_orig/"
output_bids_folder="/Users/Lisa-Katrin/Documents/GitHub/ENIGMA_AN_DTI/Reshaping/Data/bids/"

# Iterate over the files in the input data folder
for file in "${input_data_folder}AD"/* "${input_data_folder}origdata"/* "${input_data_folder}MD"/* "${input_data_folder}RD"/*; do
  if [[ -f "${file}" ]]; then
    # Print file name
    printf ${file}

    # Extract relevant information from the file name (adjust the pattern as per your file naming convention)
    subject=$(basename "${file}" | cut -d '_' -f 1 | cut -c 2-)
    modality=$(basename "${file}" | cut -d '_' -f 3)
    tensor=$(basename "${file}" | cut -d '_' -f 4)

    # Create BIDS-compliant directories if they don't exist
    mkdir -p "${output_bids_folder}"/sub-"${subject}"/ses-01/
    mkdir -p "${output_bids_folder}"/sub-"${subject}"/ses-01/dwi/

    # Generate the new BIDS-compliant file name
    # note: tensor includes .nii.gz
    new_file_name="sub-${subject}_ses-01_${modality}_${tensor}"

    # Move the file to the appropriate BIDS directory with the new name
    cp "${file}" "${output_bids_folder}"/sub-"${subject}"/ses-01/dwi/"${new_file_name}"
    
    # Write the file paths to the output text file
    echo "$${output_bids_folder}"/sub-"${subject}"/ses-01/dwi/"${new_file_name}" >> "${output_bids_folder}/imagelist.txt"
  fi
done
