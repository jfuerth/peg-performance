echo
echo "<Performance for $(basename "$PWD")>"
julia --version

julia -O3 performance.jl
echo "</Performance for $(basename "$PWD")>"
echo