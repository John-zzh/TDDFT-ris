# Auto-ris: a plugin for Turbomole to invoke the TDDFT-ris method. 
This shell script help to invoke the TDDFT-ris method for Turbomole >= 7.7.

It creates a backup for `auxbasis` and `control` file before revises them.
## prequest
- Preload the Turbmole package to use Turbmole tools `adg` `kdg`, which will be used by the this shell script.

## usage
In a finished `ridft` job directory where the control file sits, do 
```
$sh tddft-s.sh -a s -b def2-TZVP -c 
```
### keywords
- **-a** method, `s` or `sp` (TDDFT-ris or TDDFT-risp). `s`: one s type fitting function for each atom; `p`: one s type fitting function for each atom, and an extra p type fitting function for each non H atom.
- **-b** basis, like `def2-TZVP` or `def2-SVP`, same as the basis set you use for the normal calculaiton.
- **-c** revise the control file to invoke the TDDFT-s method
- **-u** The U parameter in U/R^2, U=0.2 by default. 
- **-r** restore the `auxbasis` and `control` file from backup
- **-h** help
