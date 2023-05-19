#!/bin/bash
set -e  # Stop if there is a failure

#------------- DOWNLOAD UTILITY -------------#
function download_dataset() {
    FILE=$1;
    data_dir=$2;
    URL=$3;
    CHECKSUM=$4;
   
    # Check if file already exists
    if [ -f "${data_dir}/${FILE}" ]; then
        # Exists -> check the checksum
        sha_result=$(sha256sum "${data_dir}/${FILE}" | awk '{ print $1 }')
        if [ "${sha_result}" != "${CHECKSUM}" ]; then
            rm "${data_dir}/${FILE}"
            curl -L $URL | zstd -d > "${data_dir}/${FILE}"
        fi
    else
        # Download
        curl -L $URL | zstd -d > "${data_dir}/${FILE}"
    fi

    # Validate (at this point the file should really exist)
    count=0
    while [ $count -lt 10 ]
    do
        sha_result=$(sha256sum "${data_dir}/${FILE}" | awk '{ print $1 }')
        if [ "${sha_result}" == "${CHECKSUM}" ]; then
            echo ${FILE} "checksum ok"
            break
        fi
        rm "${data_dir}/${FILE}"
        echo "wrong checksum, retrying..."
        echo "EXPECTED ${CHECKSUM}"
        echo "GOT      ${sha_result}"
        curl -L $URL | zstd -d > "${data_dir}/${FILE}"
        count=$((count+1))
    done
}

# Check if the user has provided an argument
if [ $# -eq 0 ]; then
    echo -e "\n\033[1;35m\tbash benchmark.sh <data_direcotry> [<thread_number>]\033[0m"
    echo -e "Runs the optimization benchmark. Results are saved in "{time}_optimizer.out" file."
    echo -e "Use <thread_number> to specify the number of threads to be used. If not specified, it will be set to the number of available CPUs.\n"
    exit
fi

# get data directory
data_dir=$1                          
data_dir=$(realpath $data_dir)

# Get number of threads
if [ $# -eq 1 ]; then
  # Use default number
  thread_number=$(nproc --all)
else
  thread_number=$2
fi

# Checksums
check_fb="22d5fd6f608e528c2ab60b77d4592efa5765516b75a75350f564feb85d573415"
check_wiki="097f218d6fc55d93ac3b5bdafc6f35bb34f027972334e929faea3da8198ea34d"
check_books="6e690b658db793ca77c1285c42ad681583374f1d11eb7a408e30e16ca0e450da"
check_osm="22d5fd6f608e528c2ab60b77d4592efa5765516b75a75350f564feb85d573415"

# URLs
url_fb="https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/EATHF7"
url_wiki="https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/SVN8PI"
url_books="https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/5YTV8K"
url_osm="https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/8FX9BV"

# Check if datasets are there
download_dataset "fb_200M_uint64" $data_dir $url_fb $check_fb
download_dataset "wiki_ts_200M_uint64" $data_dir $url_wiki $check_wiki
download_dataset "books_200M_uint32" $data_dir $url_books $check_books
download_dataset "osm_cellids_200M_uint64" $data_dir $url_osm $check_osm

# compile
cargo build --release

# Start optimization!
prefix=$(date +"%Y-%m-%d-%H-%M-%S")
file_name="${data_dir}/${prefix}_optimizer.out"
touch $file_name

echo "wiki_ts_200M_uint64"
echo "-------- wiki_ts_200M_uint64 --------" >> $file_name
# Start the timer
start_time=$(date +%s%N)
./target/release/rmi --threads $thread_number --optimize optimizer.json $"${data_dir}/wiki_ts_200M_uint64" >> $file_name
# Calculate the execution time
end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
# Print the execution time in nanoseconds
echo -e "Execution time: $execution_time ns\n" >> $file_name

echo "osm_cellids_200M_uint64"
echo "-------- osm_cellids_200M_uint64 --------" >> $file_name
# Start the timer
start_time=$(date +%s%N)
./target/release/rmi --threads $thread_number --optimize optimizer.json "${data_dir}/osm_cellids_200M_uint64" >> $file_name
# Calculate the execution time
end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
# Print the execution time in nanoseconds
echo -e "Execution time: $execution_time ns\n" >> $file_name

echo "fb_200M_uint64"
echo "-------- fb_200M_uint64 --------" >> $file_name
# Start the timer
start_time=$(date +%s%N)
./target/release/rmi --threads $thread_number --optimize optimizer.json "${data_dir}/fb_200M_uint64" >> $file_name
# Calculate the execution time
end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
# Print the execution time in nanoseconds
echo -e "Execution time: $execution_time ns\n" >> $file_name

echo "books_200M_uint32"
echo "-------- books_200M_uint32 --------" >> $file_name
# Start the timer
start_time=$(date +%s%N)
./target/release/rmi --threads $thread_number --optimize optimizer.json "${data_dir}/books_200M_uint32" >> $file_name
# Calculate the execution time
end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
# Print the execution time in nanoseconds
echo -e "Execution time: $execution_time ns\n" >> $file_name

rm optimizer.json









