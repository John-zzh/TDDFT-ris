#!/bin/bash


module load turbomole

for func in pbe pbe0 tpssh
do
    for basis in pure mix
    do 
        for ri in rij rijk off
        do
        
        if [ $func == 'pbe' ] && [ $ri == 'rijk' ];then
            :
        else
            dir="$func"_"$basis"_"$ri"
            mkdir $dir
            
            cd $dir
            
            cp ../{define.inp,coord,escf.slurm} ./
            
            if [ ! $basis == "pure" ];then
                sed -i "s/b all def2-TZVP/b 1 def2-TZVP/g" define.inp
            fi
                
            sed -i "s/FUNCTIONAL/$func/g" define.inp
            
            if [ $ri == 'rij' ];then
                sed -i '19a\ri' define.inp
                sed -i '20a\on' define.inp
            elif [ $ri == 'rijk' ];then
                sed -i '19a\rijk' define.inp
                sed -i '20a\on' define.inp
            else
                sed -i "s/ridft/dscf/g" escf.slurm
            fi
            
            if [ $func == 'pbe' ];then
                sed -i '41 s/$/ -m as/' escf.slurm
               
                sed -i '51 s/$/ -m as/' escf.slurm
            fi
            
            
            sbatch escf.slurm
            
            cd ..
        fi
        
        done
    done
done
    
        
        
        
        
