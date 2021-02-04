#!/usr/bin/env bash
# To download Julia visit https://julialang.org/downloads/
dir=$(cd $(dirname $0); pwd -P)
cd $dir

tries=5
if [ ! -z "$1" ]; then
  tries=$1
fi

echo "Performance for $(basename $dir)"
julia --version

echo "Building..."
time echo "Nothing to do"

echo "Running..."
for i in $(jot - 1 $tries); do
  time julia -O2 performance.jl
done

echo "Done!"
