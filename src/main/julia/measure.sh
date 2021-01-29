#!/usr/bin/env bash
# To download Julia visit https://julialang.org/downloads/
# Julia will use its own timer because the first time you run it, it will compile.
# Internally it runs once to compile, and then measures the time of the second run
dir=$(cd $(dirname $0); pwd -P)
cd $dir

tries=5

if [ ! -z "$1" ]; then
  tries=$1
fi

echo "Performance for $(basename $dir)"
julia --version

echo "Building..."

echo "Running..."
for i in $(jot - 1 $tries); do
  julia -O3 performance.jl
done

echo "Done!"
