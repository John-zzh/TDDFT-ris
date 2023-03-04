#!/bin/bash

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --job-name="escf"

copy_to_scratch="yes"
work_dir=$PWD

if [ $copy_to_scratch == "yes" ]; then
  echo "Copying working directory from \"$work_dir\" to \"$PFSDIR\""
  rsync -av --exclude="slurm-${SLURM_JOB_ID}.out" ./ $PFSDIR/
  echo "$PFSDIR" > SLURM_WORK_DIR-${SLURM_JOB_ID}
  hostname > SLURM_WORK_NODE-${SLURM_JOB_ID}

  echo "Changing directory to \"$PFSDIR\""
  cd $PFSDIR
fi

module purge
module load intel/20-1
. ~smp201/dev/turbomole/Config_turbo_env

export PARA_ARCH=SMP
export PATH=$TURBODIR/bin/‘sysname‘:$PATH

nohup escf > escf.out





if [ $copy_to_scratch == "yes" ]; then
  echo
  echo "Copying results from \"$PWD\" to \"$work_dir\""
  rsync -av --remove-source-files ./ $work_dir/
  err=$?
  if [ $err -eq 0 ]; then
    echo "Copied successfully, removing temporary files"
    rm $work_dir/SLURM_WORK_DIR-${SLURM_JOB_ID} $work_dir/SLURM_WORK_NODE-${SLURM_JOB_ID}
  fi
fi