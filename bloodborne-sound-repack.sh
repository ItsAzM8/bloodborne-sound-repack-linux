#!/bin/bash

fsb_directory="${1}"

if [[ ! -d "${fsb_directory}" ]]; then
    echo "${fsb_directory} doesn't exist. Please provide a valid path containing fsb files."
fi

# Directory to store the result of FSB -> MP3. Will be cleaned up.
fsb_extract_dir="temp_converted_fsb"

# An array of all FSB files in the directory containing FSBs.
fsb_files=($(ls "${fsb_directory}" | grep ".fsb"))

# Directory to store the repacked FSBs.
fsb_output_directory="repacked_fsb"

# Path to the fsbank executable used to repack.
# See <some-link-to-readme-i-guess> for installing in a Wine prefix.
fsb_executable_path="fsmod_wineprefix/drive_c/Program Files/FMOD SoundSystem/FMOD Studio 1.08.30/fmodstudiocl.exe"

# Cache diractory for fsbankcl.
cache_dir=cache

function repack_mp3_to_fsb {
    fsb_file_path="${1}"
    fsb_filename_no_ext=$(basename "${fsb_file_path}" .fsb)
    mp3_input_directory="${fsb_extract_dir}/${fsb_filename_no_ext}/"

    echo "Repacking ${mp3_input_directory} to FSB."

    if [[ ! -d "${fsb_output_directory}" ]]; then
        mkdir -p "${fsb_output_directory}"
    fi

    # FMod didn't provide a Linux version of fsbank until version 2.0 by the looks
    # We need to use version 1.8.30 at the latest as the MP3 encoder was removed in
    # subsequent versions. Can use the Windows version by calling Wine to do Windows
    # things.
    wine "${fsb_executable_path}" \
        -o "${fsb_output_directory}/${fsb_filename_no_ext}" "${mp3_input_directory}" \
        -format mp3 -quality 25 -recursive \
        -cache_dir "${cache_dir}" > /dev/null 2>&1
}

function fsb_to_mp3 {
    fsb_file_path="${1}"
    echo "Dumping ${fsb_file_path} to MP3..."

    fsb_filename_no_ext=$(basename "${fsb_file_path}" .fsb)

    fsb_extract_subdir="${fsb_extract_dir}/${fsb_filename_no_ext}"

    # Read file info of FSB and save as a JSON string
    json_string=$(vgmstream-cli -S 0 "${fsb_file_path}" -I -m)

    # Convert JSON string into an array so we can loop over its items.
    readarray -t json_array <<<$json_string

    for json in "${json_array[@]}"; do
        index=$(echo $json | jq '.streamInfo.index')
        name=$(echo $json | jq -r '.streamInfo.name')
        padded_index=$(printf %5s "${index}" | tr ' ' 0)
        index_directory="${fsb_extract_subdir}/${padded_index}"
        wav_path="${index_directory}/${name}.wav"
        mp3_path="${index_directory}/${name}.mp3"

        # Create the filestructure needed to repack. MP3s saved here.
        if [[ ! -d "${index_directory}" ]]; then
            mkdir -p "${index_directory}"
        fi

        # Convert subsong into a wav file.
        vgmstream-cli -s "${index}" "${fsb_file_path}" -o "${wav_path}" 1> /dev/null

        # Convert WAV file to an MP3.
        lame -V 2 "${wav_path}" "${mp3_path}" 2> /dev/null

        # Remove intermediate WAV file.
        rm "${wav_path}"
    done
}

for fsb_file in "${fsb_files[@]}"; do
    fsb_to_mp3 "${fsb_directory}/${fsb_file}"
    repack_mp3_to_fsb "${fsb_directory}/${fsb_file}"
done

echo "Cleaning up ${cache_dir}."
rm -r "${cache_dir}"
