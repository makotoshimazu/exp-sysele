#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: ./mkmovie input_file number_of_frames output_file"
    echo "Example: ./mkmovie input.mp4 1000 output.bin"
    exit -1;
fi

infile="$1"
num_frames="$2"
outfile="$3"

echo "Converting..."
mplayer -vo pnm -frames "${num_frames}" -nosound "${infile}" >/dev/null 2>&1

size=512x256

rm "${outfile}"

echo "resizing..."
for i in $(ls *.ppm); do
    echo "Processing ${i}..."
    convert "${i}" -resize "${size}" -depth 8 "i_${i}"
    convert -extent "${size}"  -composite "i_${i}" "r_${i}"
    sed -e '1,3d' "r_${i}" >> "${outfile}"
    rm "${i}" "i_${i}" "r_${i}"
done

