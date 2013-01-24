#!/bin/sh

# This file is part of the Continued-MaNGOS Project
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

## Expected param 1 to be 'a' for all, else ask some questions

## Normal log file (if not overwritten by second param
LOG_FILE="MaNGOSExtractor.log"
## Detailed log file
DETAIL_LOG_FILE="MaNGOSExtractor_detailed.log"

## Change this to a value fitting for your sys!
NUM_CPU="2"

## ! Use below only for finetuning or if you know what you are doing !

USE_AD="0"
USE_VMAPS="0"
USE_MMAPS="0"
USE_MMAPS_OFFMESH="0"

if [ "$1" = "a" ]
then
  ## extract all
  USE_AD="1"
  USE_VMAPS="1"
  USE_MMAPS="1"
else
  ## do some questioning!
  echo
  echo "Welcome to helper script to extract required dataz for MaNGOS!"
  echo "Should all dataz (dbc, maps, vmaps and mmaps be extracted? (y/n)"
  read line
  if [ "$line" = "y" ]
  then
    ## extract all
    USE_AD="1"
    USE_VMAPS="1"
    USE_MMAPS="1"
  else
    echo
    echo "Should dbc and maps be extracted? (y/n)"
    read line
    if [ "$line" = "y" ]; then USE_AD="1"; fi

    echo
    echo "Should vmaps be extracted? (y/n)"
    read line
    if [ "$line" = "y" ]; then USE_VMAPS="1"; fi

    echo
    echo "Should mmaps be extracted? (y/n)"
    echo "WARNING! This will take several hours!"
    read line
    if [ "$line" = "y" ]
    then
      USE_MMAPS="1";
    else
      echo "Only reextract offmesh tiles for mmaps?"
      read line
      if [ "$line" = "y" ]
      then
        USE_MMAPS_OFFMESH="1";
      fi
    fi
  fi
fi

## Special case: Only reextract offmesh tiles
if [ "$USE_MMAPS_OFFMESH" = "1" ]
then
  echo "Only extracting offmesh meshes"
  MoveMapGen.sh offmesh $LOG_FILE $DETAIL_LOG_FILE
  exit 0
fi

## Obtain numbe ob processes
if [ "$USE_MMAPS" = "1" ]
then
  echo "How many CPUs should be used for extracting mmaps? (1-4)"
  read line
  if [ "$line" -ge "1" -a "$line" -le "4" ]
  then
    NUM_CPU=$line
  else
    echo "Only number between 1 and 4 supported!"
    exit 1
  fi
fi

## Give some status
echo "Current Settings: Extract DBCs/maps: $USE_AD, Extract vmaps: $USE_VMAPS, Extract mmaps: $USE_MMAPS on $NUM_CPU processes"
if [ "$1" != "a" ]
then
  echo "If you don't like this settings, interrupt with CTRL+C"
  read line
fi

echo "`date`: Start extracting dataz for MaNGOS" | tee $LOG_FILE

## Handle log messages
if [ "$USE_AD" = "1" ];
then
  echo "DBC and map files will be extracted" | tee -a $LOG_FILE
else
  echo "DBC and map files won't be extracted!" | tee -a $LOG_FILE
fi
if [ "$USE_VMAPS" = "1" ]
then
  echo "Vmaps will be extracted" | tee -a $LOG_FILE
else
  echo "Vmaps won't be extracted!" | tee -a $LOG_FILE
fi
if [ "$USE_MMAPS" = "1" ]
then
  echo "Mmaps will be extracted with $NUM_CPU processes" | tee -a $LOG_FILE
else
  echo "Mmaps files won't be extracted!" | tee -a $LOG_FILE
fi
echo | tee -a $LOG_FILE

echo "`date`: Start extracting dataz for MaNGOS, DBCs/maps $USE_AD, vmaps $USE_VMAPS, mmaps $USE_MMAPS on $NUM_CPU processes" | tee $DETAIL_LOG_FILE
echo | tee -a $DETAIL_LOG_FILE

## Extract dbcs and maps
if [ "$USE_AD" = "1" ]
then
 echo "`date`: Start extraction of DBCs and map files..." | tee -a $LOG_FILE
 ad | tee -a $DETAIL_LOG_FILE
 echo "`date`: Extracting of DBCs and map files finished" | tee -a $LOG_FILE
 echo | tee -a $LOG_FILE
 echo | tee -a $DETAIL_LOG_FILE
fi

## Extract vmaps
if [ "$USE_VMAPS" = "1" ]
then
  echo "`date`: Start extraction of vmaps..." | tee -a $LOG_FILE
  vmapExtractor | tee -a $DETAIL_LOG_FILE
  echo "`date`: Extracting of vmaps finished" | tee -a $LOG_FILE
  mkdir vmaps
  echo "`date`: Start assembling of vmaps..." | tee -a $LOG_FILE
  vmap_assembler Buildings vmaps | tee -a $DETAIL_LOG_FILE
  echo "`date`: Assembling of vmaps finished" | tee -a $LOG_FILE

  echo | tee -a $LOG_FILE
  echo | tee -a $DETAIL_LOG_FILE
fi

## Extract mmaps
if [ "$USE_MMAPS" = "1" ]
then
  sh MoveMapGen.sh $NUM_CPU $LOG_FILE $DETAIL_LOG_FILE
fi
