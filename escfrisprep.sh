#!/bin/bash


usage() {
    echo "Usage:"
    echo "sh tddft-s.sh [-b s/s+p/N] [-x Fe/Ni] [-t VALUE] [-c Y/N] [-r] "
    echo "Description:"
    echo "-b: s -- one s type orbital per atom; p -- additional p orbital per non Hydrogen atom; N -- do not creat the minimal auxbasis"
    echo "-x: A list of elements that you dont want to use minimal fitting basis. They will use full RIJK fitting basis automatically"
    echo "-t: The global theta value in the orbital exponent alpha=theta/R^2. By default theta=0.2."
    echo "-c: Y -- modify the control file; N -- do not revise the control file"
    echo "-r: Recover the normal TDDFT setting (mainly control file and auxbasis file)"
    exit -1
}

s_sp='s'
revise='Y'
theta=0.2

while getopts "hrb:x:t:c" optname
do
    case "$optname" in
      "b")
        s_sp=$OPTARG
        ;;
      "x")
        excluded_elements=$OPTARG
          if [ ! -z "${excluded_elements}" ]; then
            echo "elements [ $excluded_elements ] will use the default full fitting basis"
          fi      
        ;;
      "t")
        echo "user defined theta parameter =$OPTARG"
        theta=$OPTARG
        ;;
      "c")
        revise=$OPTARG
        ;;
      "h") # Display help.
          usage
          exit 0
        ;;
      "r") # recover the normal setting
            for backup_file in $(ls *_ris_backup)
            do
                original_file=${backup_file%_ris_backup}
                cp backup_file original_file
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


if [ -x "$TURBODIR/bin/${TARCHDIR}/sdg" ]; then
    SHOWDG="$TURBODIR/bin/${TARCHDIR}/sdg"
elif [ -x "`which sdg`" ]; then
    SHOWDG="sdg"
else
    echo "no sdg tool found, please load Turbomole correctly"
    exit 0
fi
    
    
if [ "$revise" == 'Y' ] || [ "$revise" == 'y' ]; then
    echo "modify the setting, turn on RIJK and turn off xckernel"

    if [ -x "$TURBODIR/bin/${TARCHDIR}/adg" ]; then
        ADD_DG="$TURBODIR/bin/${TARCHDIR}/adg"
    elif [ -x "`which adg`" ]; then
        ADD_DG="adg"
    else
        echo "no adg tool found, please load Turbomole correctly"
        exit 0
    fi

    if [ -x "$TURBODIR/bin/${TARCHDIR}/kdg" ]; then
        KILLDG="$TURBODIR/bin/${TARCHDIR}/kdg"
    elif [ -x "`which kdg`" ]; then
        KILLDG="kdg"
    else
        echo "no adg tool found, please load Turbomole correctly"
        exit 0
    fi
    
    CONTROL_FILE=$($SHOWDG -f atoms)
    
    if [ -z "${CONTROL_FILE}" ]; then
        echo "no \$atoms data group found, please execute the escfrisprep in a Turbomole working directory"
        exit 0
    fi
    
    echo "control file is $CONTROL_FILE"
    
    CONTROL_FILE_BACKUP=$CONTROL_FILE"_ris_backup"
    
    if [ ! -f "$CONTROL_FILE_BACKUP" ];then
        echo "create $CONTROL_FILE_BACKUP" 
        cp "$CONTROL_FILE" "$CONTROL_FILE_BACKUP"
    fi

    
    $ADD_DG cbas file=auxbasis
    $KILLDG jbas
    sed -i -e '/jbas  =/d' $CONTROL_FILE
    $ADD_DG rij
    $ADD_DG rik
    $ADD_DG escfnoxc
    $ADD_DG profile
else
    echo "do not revise the $CONTROL_FILE file"
fi



if [ $s_sp == 's' ] || [ $s_sp == 's+p' ] ;then
    
    BASIS_FILE=$($SHOWDG -f basis)
    
    if [ -z "${BASIS_FILE}" ]; then
        echo "no \$basis data group found, please execute the escfrisprep in a Turbomole working directory"
        exit 0
    fi
    
    echo "generate ris auxbasis file"
    #103 elements
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
    
    declare -A radii_dict
    for No in `seq 1 $count`
    do
        radii_dict[${element[$No-1]}]=${radii[$No-1]}
    done
    
    
    if [ ! -f auxbasis_ris_backup ] && [ -f auxbasis ];then
        echo "create auxbasis_ris_backup "
        cp auxbasis auxbasis_ris_backup
    fi
    
    rm -f auxbasis
    touch auxbasis
    echo \$cbas >> auxbasis
    
    
    
    while read line; do
        # Extract the element symbol 
        cur_element=$(echo "$line" | awk '{print $1}')
    
        # Use grep to check if $cur_element is an element
        if  echo "$cur_element" | grep -q "^[[:alpha:]]*$"; then
            if [[ "${element[*]}" == *"$cur_element"* ]] &&  [[ "${excluded_elements[*]}" != *"$cur_element"* ]] ; then
                echo "included element:" $cur_element
                cur_radius=${radii_dict[$cur_element]}
                echo \* >> auxbasis
                echo $line >> auxbasis
                echo \# $cur_element >> auxbasis
                echo \* >> auxbasis
                echo '  1 s' >> auxbasis
                expo=$(echo $theta $cur_radius | awk '{printf "%.11f",$1/($2*1.8897259885789)^2}')
                echo ' ' $expo 1.0 >> auxbasis
                if [ "$s_sp" == 's+p' ] && [ "$cur_element" != 'h' ];then
                  echo '  1 p' >> auxbasis
                  echo ' ' $expo 1.0 >> auxbasis
                fi
            fi 
        fi
    done < "$BASIS_FILE"
    echo \* >> auxbasis
    echo \$end >> auxbasis
else 
    echo "do not generate ris auxbasis file"
fi







