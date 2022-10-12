#!/bin/bash

element=(h he li be b c n o f ne na mg al si p s cl ar k ca sc ti v cr mn fe co
ni cu zn ga ge as se br kr rb sr y zr nb mo tc ru rh pd ag cd in sn sb te i xe
cs ba la ce pr nd pm sm eu gd tb dy ho er tm yb lu hf ta w re os ir pt au hg tl
pb bi po at rn fr ra ac th pa u np pu am cm bk cf es fm md no lr)

radii=(0.5292 0.3113 1.6283 1.0855 0.8141 0.6513 0.5428 0.4652 0.4071 0.3618
2.165 1.6711 1.3608 1.1477 0.9922 0.8739 0.7808 0.7056 3.293 2.5419 2.4149
2.2998 2.1953 2.1 2.0124 1.9319 1.8575 1.7888 1.725 1.6654 1.4489 1.2823 1.145
1.0424 0.9532 0.8782 3.8487 2.9709 2.8224 2.688 2.5658 2.4543 2.352 2.2579
2.1711 2.0907 2.016 1.9465 1.6934 1.4986 1.344 1.2183 1.1141 1.0263 4.2433
3.2753 2.6673 2.2494 1.9447 1.7129 1.5303 1.383 1.2615 1.1596 1.073 0.9984
0.9335 0.8765 0.8261 0.7812 0.7409 0.7056 0.6716 0.6416 0.6141 0.589 0.5657
0.5443 0.5244 0.506 1.867 1.6523 1.4818 1.3431 1.2283 1.1315 4.4479 3.4332
3.2615 3.1061 2.2756 1.9767 1.7473 1.4496 1.2915 1.296 1.1247 1.0465 0.9785
0.9188 0.8659 0.8188 0.8086)

count=${#element[@]}
#103 elements

# -a s or sp
# -b basis name
# -u 0.2 by default
# -c modify the control control file


U=0.2

if [ ! -d control_backup ];then
  cp control control_backup
  cp auxbasis auxbasis_backup
fi


usage() {
    echo "Usage:"
    echo "sh tddft-s.sh [-a METHOD] [-b BASIS] [-c] [-r] "
    echo "Description:"
    echo "METHOD: s or sp"
    echo "BASIS: basis set"
    echo "-c: modify the control file"
    echo "-r: recover the normal RI-TDDFT setting"
    exit -1
}

while getopts "hra:b:u:c" optname
do
    case "$optname" in
      "a")
        echo "invoking TDDFT-$OPTARG"
        s_sp=$OPTARG
        ;;
      "b")
        echo "for basis set $OPTARG"
        basis=$OPTARG
        ;;
      "u")
        echo "U parameter set as U=$OPTARG"
        U=$OPTARG
        ;;
      "c")
          echo "modify the control file, turn on RIJK and turn off xckernel"
          # need to preload turbomole
          adg cbas file=auxbasis
          kdg jbas
          adg rij
          adg rik
          adg escfnoxc
          adg profile
        ;;
      "h") # Display help.
          usage
          exit 0
        ;;
      "r") # recover the normal setting
            cp control_backup control
            cp auxbasis_backup auxbasis
            echo "recover contol and auxbasis from backup"
            exit 0
        ;;
       ?) # Display help.
          usage
          exit 0
        ;;
    esac
    #echo "option index is $OPTIND"
done

if [ $s_sp ] && [ $basis ];then
  rm -f auxbasis
  touch auxbasis
  echo \$cbas >> auxbasis
  # echo `seq 1 $count`
  for No in `seq 1 $count`
  do
    cur_element=${element[$No-1]}
    cur_radius=${radii[$No-1]}
    echo \* >> auxbasis
    echo $cur_element $basis >> auxbasis
    echo \# $cur_element >> auxbasis
    echo \* >> auxbasis
    echo '  1 s' >> auxbasis
    # echo $U ${radii[$No-1]}
    expo=$(echo $U $cur_radius | awk  '{printf "%.16f",$1/($2*1.8897259885789)^2}'  )
    echo ' ' $expo 1.0 >> auxbasis
    if [ "$s_sp" == 'sp' ] && [ "$cur_element" != 'h' ];then
      echo '  1 p' >> auxbasis
      echo ' ' $expo 1.0 >> auxbasis
    fi
  done
  echo \* >> auxbasis
  echo \$end >> auxbasis
fi
