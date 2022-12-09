# escfrisprep: a plugin for the TDDFT-ris and TDDFT-ris+p method in TURBOMOLE 7.7 
This automative shell script invokes the TDDFT-ris method for Turbomole >= 7.7.

The script inplace revises the `auxbasis` and `control` file, after creating a backup for them.
## prequest
- Preload the Turbmole package (such as `module load turbomole`) to enable Turbmole tools `adg` `kdg`, which will be used by the this shell script.

## usage
In a finished `ridft` job directory where the control file exists, do 
```
$sh escfrisprep.sh -a s -c 
```
### keywords
- **-a** method, `s` or `s+p` (TDDFT-ris or TDDFT-ris+p). `s`: one s type fitting function for each atom; `s+p`: one s type fitting function for each atom, and an extra p type fitting function for each non-H atom.
- **-b** basis, like `def2-TZVP` or `def2-SVP`, same as the basis set you use for the SCF calculaiton.
- **-c** revise the control file to invoke the TDDFT-ris or TDDFT-ris+p method
- **-u** Asign the $\theta$ value in exponent $\alpha_A = \theta/R_A^2$ for atom $A$. By default, $\theta=0.2$. 
- **-r** restore the `auxbasis` and `control` file from backup
- **-h** help
