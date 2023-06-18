#!/bin/bash

    echo
    echo "             +--------------------------------------+"
    echo "             |            escfrisprep               |"
    echo "             |  prepare for TDDFT-ris calculations  |"
    echo "             |           with TURBOMOLE             |"
    echo "             +--------------------------------------+"
    echo 
    echo "   Ref: 1. Z. Zhou, F. Della Sala, S. M. Parker,         " 
    echo "           J. Phys. Chem. Lett. 2023, 14, 7, 1968–1976   "
    echo "        2. G. Giannone, F. Della Sala.,                  " 
    echo "           J. Chem. Phys. 2020, 153, 084110              "
    echo "                     $(date)                             "
    echo

usage() {
    echo "Usage:"
    echo "sh escfrisprep.sh [-b s/s+p/N] [-x Fe] [-x Ag] [-t VALUE]  [-c Y/N] [-m auto/as/ris] [-g Y/N] [-r] "
    echo "Description:"
    echo "-b: s -- one s type orbital per atom; p -- additional p orbital per non Hydrogen atom; N -- do not creat the minimal auxbasis. Default: s"
    echo "-x: The element that you dont want to use the full RIJK fitting basis. Use -x multiple times if you want to exclude more than one element: -x ag -x au.  Default: none"
    echo "-t: The global theta value in the orbital exponent alpha=theta/R^2. Default: 0.2."
    echo "-c: Y -- modify the control file; N -- do not revise the control file.  Default: Y"
    echo "-m: as -- use pure density functional (TDDFT-as); ris -- use hybrid or RSH functional (TDDFT-ris);auto -- autmatically detect the type of functional. Default: auto. This option only matters using pure density functional and excluding some elements that will use default RIJ fitting basis"
    echo "-g: Y -- revise the gridsize. This option is for the dvelopmental version of Turomole that has not fully kill the grid in TDDFT-ris codes. Default: N"
    echo "-r: Recover the original setting from backup (mainly control file and auxbasis file)"
    exit -1
}

if [ -x "$TURBODIR/bin/${TARCHDIR}/sdg" ]; then
    SHOWDG="$TURBODIR/bin/${TARCHDIR}/sdg"
elif [ -x "`which sdg`" ]; then
    SHOWDG="sdg"
else
    echo "no sdg tool found, please load Turbomole correctly"
    exit 0
fi

CONTROL_FILE=$($SHOWDG -f atoms)
if [ -z "${CONTROL_FILE}" ]; then
    echo "no \$atoms data group found, please execute the escfrisprep in a Turbomole working directory"
    exit 0
fi

SCF_DG=$($SHOWDG scfinstab)
# echo $SCF_DG
if [[ "$SCF_DG" =~ 'rpas' ]];then
    echo "rpa detected"
elif [[ "$SCF_DG" =~ 'ciss' ]];then
    echo "ciss detected"
else
    echo "no rpas or ciss found in \$scfinstab data group, please specify one of them"
    exit 0
fi

if [[ -z $($SHOWDG 'closed shells') ]];then
    echo "WARNING: you are working on open shell system."
    echo "TDDFT-ris has smaller errors on closed shell systems"
fi

s_sp='s'
revise='Y'
theta=0.2
method='auto'
revise_g='N'

while getopts "hrb:x:t:c:m:g:" optname
do
    case "$optname" in
      "b")
        s_sp=$OPTARG
        ;;
      "x")
        lower=$(echo $OPTARG | awk '{print tolower($0)}')
        excluded_elements+=($lower)
          if [[ ! -z $OPTARG ]]; then
            echo "elements [ $OPTARG ] will use the default full fitting basis"
          fi      
        ;;
      "t")
        echo "user defined theta parameter =$OPTARG"
        theta=$OPTARG
        ;;
      "c")
        revise=$OPTARG
        ;;
      "m")
        method=$OPTARG
        ;;
       "g") #revise the grid settting
        revise_g=$OPTARG
        ;;
      "h") # Display help.
          usage
          exit 0
        ;;
      "r") # recover the normal setting
            for backup_file in $(ls *_ris_backup)
            do
                original_file=${backup_file%_ris_backup}
                echo "restore $original_file from $backup_file"
                mv $backup_file $original_file
            done
            
            use_ri=$($SHOWDG -f ri)
            if [ -z "${use_ri}" ]; then
                echo "The original calculation did not use RI, remove auxbasis"
                rm auxbasis
            fi
            
            echo "recover the original setting from backup"
            exit 0
        ;;
       ?) # Display help.
          usage
          exit 0
        ;;
    esac
    #echo "option index is $OPTIND"
done


if [[ "$method" == 'auto' ]]; then                   
    FUNC_TYPE=$($SHOWDG xctype | awk '{print $2}')
    ISDFT=$($SHOWDG dft) 
    if [[ ! -z "$ISDFT" ]]; then 
    if [[ -z "$FUNC_TYPE" ]]; then
      echo "!!! WARNING !!! \$xctype not found in control"
      echo "assuming TDDFT-ris"   
      method='ris'
    else
     echo "method is auto; xctype= " $FUNC_TYPE
     if [[ "$FUNC_TYPE" == 'LDA' || "$FUNC_TYPE" == 'GGA' || "$FUNC_TYPE" == 'MGGA' ]]; then
        method='as'
     elif [[ "$FUNC_TYPE" == 'localhyb' ]]; then
        echo "Local Hybrids not supported"
        exit -1
     else
        method='ris'  
     fi
    fi
    else
      echo "Ground-state is Hartee-Fock"
      echo "assuming TDDFT-ris"
      method='ris'            
    fi
fi

if [[ "$method" == 'as' ]]; then
    echo "method is TDDFT-as : minimal auxbasis for Coulomb"
    XBAS='jbas'
elif  [[ "$method" == 'ris' ]]; then 
    echo "method is TDDFT-ris : minimal auxbasis for Coulomb and Exchange"
    XBAS='cbas'
else
   echo "Method " $method "is incorrect"
   exit -1 
fi

echo "minimal auxbasis in " "\$"$XBAS

sizebas=`$SHOWDG $CBAS | wc -l` 
#echo $sizebas
if [[  "$sizebas" -lt "2" ]]; then  
 echo "no \$"$CBAS  "found" 
 if [[ "$CBAS" == "cbas" ]]; then
  echo "Set up an ordinary calculation TDDFT calculation RIJK (hybrid XC)"      
 elif [[ "$CBAS" == "jbas" ]]; then        
  echo "Set up an ordinary calculation TDDFT calculation RIJ (semilocal XC)"                
 fi
 exit -1  
fi

echo "theta is " $theta   

    
    
add_sub_data(){
    # echo $1
    # echo $2
  # $1 = gridsize, keyword
  # $2 = gridsize 1, new keyword

  if [[ "$(grep $1 $CONTROL_FILE)" != "" ]];then # already has "gridsize"
      sed -i "s/^.*$1.*$/ $2/" $CONTROL_FILE
  else
      sed -i "/functional/a\ $2" $CONTROL_FILE
  fi
  echo "added to \$dft data group: $2"
}
    
if [[ "$revise" == "Y" || "$revise" == "y" ]]; then
    echo "modify the setting, turn on RIJK and turn off xckernel"

    if [[ -x "$TURBODIR/bin/${TARCHDIR}/adg" ]]; then
        ADD_DG="$TURBODIR/bin/${TARCHDIR}/adg"
    elif [[ -x "`which adg`" ]]; then
        ADD_DG="adg"
    else
        echo "no adg tool found, please load Turbomole correctly"
        exit 0
    fi

    if [[ -x "$TURBODIR/bin/${TARCHDIR}/kdg" ]]; then
        KILLDG="$TURBODIR/bin/${TARCHDIR}/kdg"
    elif [[ -x "`which kdg`" ]]; then
        KILLDG="kdg"
    else
        echo "no adg tool found, please load Turbomole correctly"
        exit 0
    fi
    

    
    echo "control file is $CONTROL_FILE"
    
    CONTROL_FILE_BACKUP=$CONTROL_FILE"_ris_backup"
    
    if [ ! -f "$CONTROL_FILE_BACKUP" ];then
        echo "create $CONTROL_FILE_BACKUP" 
        cp "$CONTROL_FILE" "$CONTROL_FILE_BACKUP"
    fi

    
    if [[ "$method" == 'ris' ]];then
        $KILLDG jbas
        sed -i -e '/jbas  =/d' $CONTROL_FILE
        $ADD_DG rik
    fi
    
    $ADD_DG "$CBAS" file=auxbasis
    $KILLDG jkbas
    sed -i -e '/jkbas =/d' $CONTROL_FILE
    $ADD_DG rij
    $ADD_DG escfnoxc
    $ADD_DG profile
    if [[ "$revise_g" == "Y" || "$revise_g" == "y" ]]; then
        add_sub_data 'gridsize' 'gridsize 1'
        add_sub_data 'gridtype' 'gridtype 0'
        add_sub_data 'radsize' 'radsize 1'
    fi
    echo "$CONTROL_FILE file revision done"
else
    echo "you choose not to revise the $CONTROL_FILE file"
fi



if [ $s_sp == 's' ] || [ $s_sp == 's+p' ] ;then
    
    BASIS_FILE=$($SHOWDG -f basis)
    
    if [ -z "${BASIS_FILE}" ]; then
        echo "no \$basis data group found, please execute the escfrisprep in a Turbomole working directory"
        exit 0
    fi
    
    echo "generate ris auxbasis file"
    #103 elements
    elements=(h he li be b c n o f ne na mg al si p s cl ar k ca sc ti v cr mn fe co
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
    count=${#elements[@]}
    
    declare -A radii_dict
    for No in `seq 1 $count`
    do
        radii_dict[${elements[$No-1]}]=${radii[$No-1]}
    done
    
    
    if [ ! -f auxbasis_ris_backup ] && [ -f auxbasis ];then
        echo "create auxbasis_ris_backup "
        cp auxbasis auxbasis_ris_backup
    fi
    
    rm -f auxbasis
    touch auxbasis
    echo \$"$CBAS" >> auxbasis
    
    
    
    is_excluded() {

        for item in  ${excluded_elements[@]}
        do
            if [[ "$1" == "$item" ]]; then
                return 0  # Variable found in list, return success
            fi
        done
        return 1 
    }  
    
    
    while read line; do
        # Extract the element symbol from the first word of each line of basis file
        cur_element=$(echo "$line" | awk '{print $1}')
    
        # Use grep to check if $cur_element is pure letter
        if echo "$cur_element" | grep -q "^[[:alpha:]]*$"; then
            if is_excluded $cur_element; then
                echo "excluded element: $cur_element will use full fitting basis"
            else
                echo "included element: $cur_element" 
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
    echo "you choose not to generate ris auxbasis file"
fi







