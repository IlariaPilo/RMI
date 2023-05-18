#!/bin/bash
set -e  # Stop if there is a failure

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

# Check if datasets are there
if [ ! -e "${data_dir}/wiki_ts_200M_uint64" ]; then
    curl -L https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/SVN8PI | zstd -d > "${data_dir}/wiki_ts_200M_uint64"
fi
if [ ! -e "${data_dir}/osm_cellids_200M_uint64" ]; then
    curl -L https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/8FX9BV | zstd -d > "${data_dir}/osm_cellids_200M_uint64"
fi
if [ ! -e "${data_dir}/fb_200M_uint64" ]; then
    curl -L https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/EATHF7 | zstd -d > "${data_dir}/fb_200M_uint64"
fi
if [ ! -e "${data_dir}/books_200M_uint32" ]; then
    curl -L https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/JGVF9A/5YTV8K | zstd -d > "${data_dir}/books_200M_uint32"
fi

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









