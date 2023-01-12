#!/bin/bash

# this template simulate having just 2 gpus installed

# Set locked GPU clock
nvidia-smi -i 0 -lgc 1500
nvidia-smi -i 1 -lgc 1500

# Set Power limits
nvidia-smi -i 0 -pl 70
nvidia-smi -i 1 -pl 130

# Init X
xinit & export DISPLAY=:0.0


# Set  memory offsets
nvidia-settings -a GpuPowerMizerMode=1

nvidia-settings -c :0 -a '[gpu:0]/GPUMemoryTransferRateOffsetAllPerformanceLevels=-1004'
nvidia-settings -c :0 -a '[gpu:1]/GPUMemoryTransferRateOffsetAllPerformanceLevels=2000'

# Set FAN speed
nvidia-settings -a GPUFanControlState=1

nvidia-settings -a "[fan:0]/GPUTargetFanSpeed=60"
nvidia-settings -a "[fan:1]/GPUTargetFanSpeed=70"

# Start miner

# use here your seleted miner command with his config
