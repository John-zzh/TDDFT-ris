# TDDFT-s
A plugin for Turbomole input file to invoke the TDDFT-s method
## request
only use `gridsize 4` in the control file.

Preload the Turbmole package to use Turbmole tools `adg` `kdg`, which will be used by the plugin.

## usage
In a Turbomole working directory where the control file sits, do 
```
$sh tddft-s.sh -a s -b def2-TZVP -c 
```
### keywords
- **-a** method, `s` or `sp` (TDDFT-s or TDDFT-sp). `s`: one s type fitting function for each atom; `p`: one s type fitting function for each atom, and an extra p type fitting function for each non H atom.
- **-b** basis, like `def2-TZVP` or `def2-SVP`, same as the basis set you use for the normal calculaiton.
- **-c** revise the control file to invoke the TDDFT-s method
- **-u** The U parameter in U/R^2, U=0.2 by default. 
