#!/bin/bash
#
# Copyright 2021-2023 Ionuț Iosifescu-Enescu (ionut.iosifescu@wsl.ch)
# Script adapted after Iosifescu et al. (2022), https://www.doi.org/10.16904/envidat.230
# Affiliation: Swiss Federal Institute for Forest, Snow and Landscape Research WSL
# 
# This bash script is released under the MIT permissive free software license below.
# The MIT license has been chosen to conform with the best practices for Open Science. 
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# REQUIREMENTS: Before running this script make sure that WGET, GDAL and FFMPEG are installed.
#
echo "************************************************************************************"
echo "This bash script is released under the MIT permissive free software license."
echo "The MIT license has been chosen to conform with the best practices for Open Science."
echo "This script processes data that 'Contains modified Copernicus Sentinel data [2018-2021]'."
echo "************************************************************************************"
echo "Before running we check that WGET, GDAL and FFMPEG are properly installed in the container."
if command -v ffmpeg &> /dev/null
then
    FFMPEG="$(which ffmpeg)"
    echo "FFMPEG found in: $FFMPEG"
else
  echo "FFMPEG was not found on this system. Exiting."
  exit 1
fi
if command -v gdal_translate &> /dev/null
then
    GDAL="$(which gdal_translate)"
    echo "GDAL_TRANSLATE found in: $GDAL"
else
  	echo "GDAL was not found on this system. Exiting."
exit 1
fi
if command -v wget &> /dev/null
then
    WGET="$(which wget)"
    echo "WGET found in: $WGET"
else
  	echo "WGET was not found on this system. Exiting."
exit 1
fi

SOURCE_DIRECTORY="0_source"
INPUT_DIRECTORY="1_input_untiled"
TILE_DIRECTORY_TC="1_input_tile_contiguous"
CORE_DIRECTORY="2_core_stream"
OVR_INPUT_DIRECTORY="1_input_ovr"
CORE_SELECTION_DIRECTORY="3_core_selected"

mkdir $INPUT_DIRECTORY # Creating the input directory.
rm ./$INPUT_DIRECTORY/* # Making sure the directory is empty.
mkdir $TILE_DIRECTORY_TC # Creating the input directory.
rm ./$TILE_DIRECTORY_TC/* # Making sure the directory is empty.
mkdir $CORE_DIRECTORY # Creating the CORE output directory.
rm ./$CORE_DIRECTORY/* # Making sure the directory is empty.
mkdir $OVR_INPUT_DIRECTORY # Creating the input directory for the overview files.
rm ./$OVR_INPUT_DIRECTORY/* # Making sure the directory is empty.

wget -P ./$SOURCE_DIRECTORY -nc https://os.zhdk.cloud.switch.ch/envicloud/wsl/CORE_S2A/0_source/envidatS3paths.txt

WgetFile=./$SOURCE_DIRECTORY/envidatS3paths.txt
if [ -f "$WgetFile" ]; then
    wget -P ./$SOURCE_DIRECTORY -nc -i $WgetFile
else 
    echo "Could not retrieve source data. Check your Internet connection. Exiting."
exit 1
fi

# Defining a reduced clip extent for demonstration purposes
XMIN="434000"
XMAX="485200"
YMIN="5218800"
YMAX="5270000"
# Defining tile size: 512 pixels; pixelsize of 10m
TILESIZE="5120"
echo "Defined clip extent: X coordinate from $XMIN to $XMAX and Y coordinate from $YMIN to $YMAX "
echo "FFMPEG cannot directly import S2 data, thus we need to convert imagery layers to PNG."
echo "PNG is used due to its LOSSLESS compression (data is not changed during conversion)."
i="1" # Initializing interator for the sequence.
filelist="s2a.txt" # File for saving the file base names.
printf -v count $(ls ./$SOURCE_DIRECTORY/*.jp2| wc -l)
echo "S2 products: $count"
if [ $count -eq 50 ]
then
	for f in $SOURCE_DIRECTORY/*.jp2
	do
		k="1" # Initializing iterator for the sequence.
  		printf -v n "%02d" $i
  		filebase=${f##*/}
  		echo ${filebase%.jp2} >> ./$CORE_DIRECTORY/$filelist
  		echo "Transforming untiled source file ${f##*/} into PNG for FFMPEG encoding ..."
		gdal_translate -of PNG -co "WORLDFILE=YES" -projwin $XMIN $YMAX $XMAX $YMIN ${f} "./${INPUT_DIRECTORY}/$n.png"
		echo "Generating and ordering tiles for both layer contiguous and tile contiguous encoding ..."
		x="$XMIN"
   		y="$YMAX"
		while [ "$y" != "$YMIN" ] 
		do
			while [ "$x" != "$XMAX" ]
			do 
   			printf -v m "%03d" $k
   			ulx=$[$x]
   			uly=$[$y]
   			lrx=$[$x + $TILESIZE]
   			lry=$[$y - $TILESIZE]
   			x=$[$x + $TILESIZE]
   			echo "Generating $m with -projwin $ulx $uly $lrx $lry"
   			gdal_translate -of PNG -co "WORLDFILE=YES" -projwin $ulx $uly $lrx $lry ${f} "./$TILE_DIRECTORY_TC/"$m"_"$n".png"
   			k=$[$k+1]
   			done
   			x="$XMIN"
   			y=$[$y - $TILESIZE]
		done
		echo "Creating lower resolution PNG input images for the overview ..."
		gdal_translate -of PNG -outsize 10% 0 -co "WORLDFILE=YES" -projwin $XMIN $YMAX $XMAX $YMIN ${f} "./${OVR_INPUT_DIRECTORY}/$n.png"
  		i=$[$i+1]
	done
	i="1" # Reinitializing interator for the sequence.
	metadata_filelist=""
	while read -r line
    do
        printf -v j "%02d" $i
    	metadata_filelist+="-metadata $j=\"${line}\" "
    	i=$[$i+1]
    done < "$filelist"
	echo "Converting generated time series to CORE mp4 format using the H.264 codec ..."
	echo "(The AV1 codec has not been used due to the VERY long time required for encoding)"
	echo "INFO: The h264 encoding takes a significantly shorter time than AV1 encoding."
	echo "Producing compressed tile contiguous H.264 CORE ..."
	for j in {23..23}
	do
		printf -v i "%02d" $j
		echo $metadata_filelist
   		echo "Producing tile contiguous H.264 CORE with CRF $i ..."
   		time ffmpeg -hide_banner -framerate 1 -pattern_type  glob -i "./$TILE_DIRECTORY_TC/*.png" -vcodec h264 -pix_fmt yuv420p -crf $i -an -tune fastdecode -tune zerolatency -movflags faststart ./${CORE_DIRECTORY}/CORE_h264_temp.mp4
   		echo "Adding metadata ..."
   		ffmpeg -i ./${CORE_DIRECTORY}/CORE_h264_temp.mp4 -movflags use_metadata_tags -metadata notice="Contains modified Copernicus Sentinel data [2018-2021]" -metadata layers="50" -metadata tiles="100" -metadata tileschema="TC" -metadata PAMXML="<PAMDataset><SRS dataAxisToSRSAxisMapping=\"1,2\">AUTHORITY[\"EPSG\",\"32632\"</SRS><Metadata domain=\"IMAGE_STRUCTURE\"></Metadata><Metadata><MDI key=\"AREA_OR_POINT\">Area</MDI></Metadata></PAMDataset>" -metadata title="S2A data in CORE format" -metadata year="2021" -metadata author="ionut.iosifescu@wsl.ch" -metadata copyright="CC0" $metadata_filelist -c copy ./${CORE_DIRECTORY}/CORE_h264_"$i"_tc.mp4
		cp ./${INPUT_DIRECTORY}/01.wld ./${CORE_DIRECTORY}/CORE_h264_"$i"_tc.mp4.wld
   		cp ./${INPUT_DIRECTORY}/01.png.aux.xml ./${CORE_DIRECTORY}/CORE_h264_"$i"_tc.mp4.aux.xml
   		rm ./${CORE_DIRECTORY}/CORE_h264_temp.mp4
   		echo "Producing streamable overviews with CRF $i with the H.264 codec for wide browser compatibility ..."
   		time ffmpeg -hide_banner -framerate 1 -pattern_type  glob -i "./$OVR_INPUT_DIRECTORY/*.png" -vcodec h264 -pix_fmt yuv420p -crf $i -an -tune fastdecode -tune zerolatency -movflags faststart ./${CORE_DIRECTORY}/CORE_h264_temp.mp4
   		ffmpeg -i ./${CORE_DIRECTORY}/CORE_h264_temp.mp4 -movflags use_metadata_tags -metadata notice="Contains modified Copernicus Sentinel data [2018-2021]" -metadata layers="50" -metadata tiles="1" -metadata tileschema="U" -metadata PAMXML="<PAMDataset><SRS dataAxisToSRSAxisMapping=\"1,2\">AUTHORITY[\"EPSG\",\"32632\"</SRS><Metadata domain=\"IMAGE_STRUCTURE\"></Metadata><Metadata><MDI key=\"AREA_OR_POINT\">Area</MDI></Metadata></PAMDataset>" -metadata title="S2A data in CORE format" -metadata year="2021" -metadata author="ionut.iosifescu@wsl.ch" -metadata copyright="CC0" $metadata_filelist -c copy ./${CORE_DIRECTORY}/CORE_h264_"$i".ovr.mp4
   		rm ./${CORE_DIRECTORY}/CORE_h264_temp.mp4	
	done
	echo "All DONE! The script for reproducing the results has completed. Thank you for your patience!"
else
echo "Expected source files not found on this system. Exiting."
fi
