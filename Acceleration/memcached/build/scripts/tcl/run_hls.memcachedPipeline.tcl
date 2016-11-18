open_project memcachedPipeline_prj

set_top memcachedPipeline

add_files ../src/hls/memcachedPipeline/hashTable/cc.cpp
add_files ../src/hls/memcachedPipeline/hashTable/compare.cpp
add_files ../src/hls/memcachedPipeline/hashTable/hash.cpp
add_files ../src/hls/memcachedPipeline/hashTable/hashTable.cpp
add_files ../src/hls/memcachedPipeline/hashTable/memRead.cpp
add_files ../src/hls/memcachedPipeline/hashTable/memWrite.cpp
add_files ../src/hls/memcachedPipeline/requestParser/requestParser.cpp
add_files ../src/hls/memcachedPipeline/responseFormatter/binResponse.cpp
add_files ../src/hls/memcachedPipeline/valueStore/valueStore.cpp
add_files ../src/hls/memcachedPipeline/valueStore/flashValueStore.cpp
add_files ../src/hls/memcachedPipeline/globals.cpp
add_files ../src/hls/memcachedPipeline/merger.cpp
add_files ../src/hls/memcachedPipeline/splitter.cpp
add_files ../src/hls/memcachedPipeline/memcachedPipeline.cpp
add_files -tb ../src/hls/memcachedPipeline/memcachedPipeline_tb.cpp

open_solution "solution1"
set_part {xc7vx690tffg1157-2}
create_clock -period 6.66 -name default
config_rtl -reset all -reset_async

csynth_design
export_design -format ip_catalog -display_name "Combined Binary Flash/DRAM Memcached Pipeline" -description "A 4 stage memcached pipeline with SSD & DRAM value stores supporting only the binary protocol" -vendor "xilinx.labs" -version "1.07"
exit
