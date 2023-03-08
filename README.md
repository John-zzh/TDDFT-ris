
# escfrisprep: a plugin for the TDDFT-ris and TDDFT-ris+p method in TURBOMOLE
This automative shell script invokes the TDDFT-ris method for Turbomole developmental version. Hopefully the release right after TURBOMOLE 7.7.

The script in-place revises `control` file and generate a new `auxbasis` file, after creating a backup for them.

Note: a python implementation for TDDFT-ris (based on PySCF) is also available, see [https://github.com/John-zzh/pyscf-ris](https://github.com/John-zzh/pyscf-ris)

## Prequest
- Preload the Turbmole package (such as `module load turbomole`) to enable Turbmole tools `sdg` `adg` `kdg`, which will be used by the this shell script. Otherwise this script will not work.

## Usage
In a finished `ridft` job directory where the `control` file exists, to invoke TDDFT-ris method:
```
$sh escfrisprep.sh
```

To invoke TDDFT-risp method:
```
$sh escfrisprep.sh -b s+p
```


To invoke TDDFT-ris method with a pure functional:
```
$sh escfrisprep.sh -m as
```

To invoke TDDFT-ris method on transition metal complex, i.e. ferrocene, with full fitting basis on `Fe` element:
```
$sh escfrisprep.sh -x fe
```

To restore your previous standard settings:
```
$sh escfrisprep.sh -r
```

## Keywords

- **-b** `s`: one s type fitting function for each atom; `s+p`: one s type fitting function for each atom, and an extra p type fitting function for each non-H atom; `N`: do not create the minimal auxbasis. Default: `s`
- **-x** A list of elements (in lower case) that you want to use full fitting basis. They will use full RIJK (RIJ in the case of pure density functional) fitting basis. Default:  (no exclusion)
- **-m** `as`: use pure density functional; `ris`: use hybrid or RSH functional. This option only matters when using pure density functional and exclude some elements. Because those elements will use default RIJ fitting basis rather than RIJK. Default: `ris`
- **-t** Asign the $\theta$ value in exponent $\alpha_A = \theta/R_A^2$ for atom $A$. Default: `0.2`.
- **-c** `Y`: modify the control file; `N`: do not revise the control file. Default: `Y`
- **-r**  Restore the original setting from backup (mainly control file and auxbasis file).
- **-h**  Help page


## Reference
1. [Zhou, Z., Della Sala, F. and Parker, S.M., 2023. Minimal auxiliary basis set approach for the electronic excitation spectra of organic molecules. The Journal of Physical Chemistry Letters, 14, 7, 1968-1976.](https://pubs.acs.org/doi/10.1021/acs.jpclett.2c03698)
2. [Giannone, G. and Della Sala, F., 2020. Minimal auxiliary basis set for time-dependent density functional theory and comparison with tight-binding approximations: Application to silver nanoparticles. The Journal of Chemical Physics, 153(8), p.084110.](https://doi.org/10.1063/5.0020545)
