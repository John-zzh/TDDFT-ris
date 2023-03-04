
# escfrisprep: a plugin for the TDDFT-ris and TDDFT-ris+p method in TURBOMOLE
This automative shell script invokes the TDDFT-ris method for Turbomole developmental version. Hopefully the release right after TURBOMOLE 7.7.

The script inplace revises the `auxbasis` and `control` file, after creating a backup for them.

Note: a python implementation for TDDFT-ris (based on PySCF) is also available, see [https://github.com/John-zzh/pyscf-ris](https://github.com/John-zzh/pyscf-ris)

## Prequest
- Preload the Turbmole package (such as `module load turbomole`) to enable Turbmole tools `adg` `kdg`, which will be used by the this shell script.

## Usage
In a finished `ridft` job directory where the `control` file exists, do
```
$sh escfrisprep.sh 
```
## Keywords
- **-b** method, `s` or `s+p` (TDDFT-ris or TDDFT-ris+p). `s`: one s type fitting function for each atom; `s+p`: one s type fitting function for each atom, and an extra p type fitting function for each non-H atom; `N`: do not creat the minimal auxbasis
- **-x** A list of elements (in lower case) that you dont want to use minimal fitting basis. They will use full RIJK fitting basis automatically.
- **-t** Asign the $\theta$ value in exponent $\alpha_A = \theta/R_A^2$ for atom $A$. By default, $\theta=0.2$.
- **-c** `Y`: modify the control file; `N`: do not revise the control file
- **-r** Recover the original setting from backup (mainly control file and auxbasis file).
- **-h** help page


## Reference
1. [Zhou, Z., Della Sala, F. and Parker, S.M., 2023. Minimal auxiliary basis set approach for the electronic excitation spectra of organic molecules. The Journal of Physical Chemistry Letters, 14, 7, 1968-1976.](https://pubs.acs.org/doi/10.1021/acs.jpclett.2c03698)
2. [Giannone, G. and Della Sala, F., 2020. Minimal auxiliary basis set for time-dependent density functional theory and comparison with tight-binding approximations: Application to silver nanoparticles. The Journal of Chemical Physics, 153(8), p.084110.](https://doi.org/10.1063/5.0020545)
