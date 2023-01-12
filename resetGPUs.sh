#!/bin/bash

# SET HERE YOUR NUMBER OF GPUs INSTALLED
NUMGPUS=6

# reset GPU clocks
nvidia-smi --reset-gpu-clocks

# Init X
xinit & export DISPLAY=:0.0
PID=$!

# Reset OC offsets
nvidia-settings -a GpuPowerMizerMode=1

for ((i = 0 ; i < $NUMGPUS ; i++)); do
  nvidia-settings -c :0 -a '[gpu:'$i']/GPUMemoryTransferRateOffsetAllPerformanceLevels=0'
done

# Reset FAN speed
nvidia-settings -a 'GPUFanControlState=1'

for ((i = 0 ; i < $NUMGPUS ; i++)); do
  nvidia-settings -a '[fan:'$i']/GPUTargetFanSpeed=1'
done

nvidia-settings -a 'GPUFanControlState=0'

# Kill X
kill -INT $PID
