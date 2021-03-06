## 20190202
* 

## 20170729 0.0.2.9003
* push to remote
* remove unused line in travis


## 20170714 0.0.2.9002
* remove two unit tests in test_nodal_status.R. They were too explicit to the source folders and making the pkg crash.
* running coverage results. Had to remove two test functions in test_LL_paths.R
        > covr::package_coverage()
        rNodal Coverage: 52.18%
        R/all_generics.R: 0.00%
        R/class-VLP.R: 0.00%
        R/Fancher-Brown.R: 0.00%
        R/heat_transfer.R: 0.00%
        R/interpolation.R: 0.00%
        R/Poettmann-Carpenter.R: 0.00%
        R/zzz.R: 0.00%
        R/friction.R: 1.79%
        R/settings.R: 7.41%
        R/class-well_deviation_survey.R: 30.67%
        R/Duns-Ros.R: 35.56%
        R/utils.R: 42.70%
        R/gas_correlations.R: 57.66%
        R/hdf5.R: 73.33%
        R/Hagedorn-Brown.R: 74.70%
        R/oil_correlations.R: 78.05%
        R/VLP.R: 94.79%
        

## 20170710 0.0.2.9001
* add Hmisc to Imports to use list.tree in vignette C13
* use pres. average instead of pres at the end
* change name of test dataset to brown_oilwell01.rda
* add function temp.fluid to calculate fluid temperaturem to heat_transger.R
* add VLP class to class-VLP.R. But not used yet
* add notebook to test VLP class
* add new script all_generics.R
* calculate the mass flow rate w = m * q
* move mass.rate object from Hagedorn-Brown.R to VLP.R
* copy example from heat_transfer notebook to vignette C13
* add U, oil.cp, gas.cp, wat.cp to well input
* add calculation of Cp average
* add new function get_well_parameters that combines the well input and the basic calculations
* add functions shift and na.zero to calculate the angle of a deviation survey.
* finding angle from MD, TVD working
* add diam.organize notebook on "build deviation survey with angles". add sections.ft object because causes vignette C13 to crash
* Merge branch 'mass.rate_to_well_params' into feature/0.0.2.9001
* Merge branch 'feature/0.0.2.9001' into develop

## 20170709 0.0.2.9000
* rename VLP scripts to author names separated by dashes.
* move functions in dunsros.R to own script.
* move any gas fucntion to gas_correlations.R
* rename FLUIDPROPS.R to oil_correlations.R
* move functions in zfactor.R to gas_correlations.R
* remove data.R. move its functions to rNodal-package.r
* no Rd for .saveSlot function

## 20170709 0.0.2
* document few functions
* ignore folder notebooks


## 20170709 0.0.1.9003
* use Hall-Yarborough from zFactor
* remove old HY built-in in this package
* new datasets in testthat regenerated with new values of z with zFactor
* add more tests to test_zfactor.R
* use zFactor::HallYarborough directly in the tests supplying sequences of Ppr and Tpr that are in a reasonable range of oil wells.
* using zFactor::HallYarborough at low and high Ppr, Tpr
* create a rda file for test check zFactor with returning lists of z, pres.pr, temp.pr and temp.r


## 20170709 0.0.1.9002
* add links to h5 files in vignettes
* h5 temp file is the same for all vignettes VLP runs
* VLP tables are added to h5 in temp file unless R session is restarted
* add word test to all test files
* add new test for all VLP runs that were in vignettes. 
* each VLP test now has its own rda file for test check
* add verbose to functions VLPControl and hdf5 creation function
* rename surf.params to well.params

## 20170707 0.0.1.9001
* change source of notebooks to ../R
* re-running vignettes
* remove html and R from vignettes
* rename one vignette
* add title to index vignette


## 20170706 0.0.1.9000
* all tests running ok
* move folders from inst to notebooks
* improve strategy


## 20170706 0.0.1
* keeping 9012 as a base
* changes to z return values were discarded; causing problems

## 20170611 9012
* fix two tests in test_nodal_status.R because of a change of folder in rNodal.

## 20170611 9011
* add new file STRATEGY.md

## 20170611 9010
* changes in z factor
* new equation for z.
* strategy to extract single values instead of list

## 20170605 9008
* FIX problem with interpolation.R. It was renamed but this causes conflicts 
with existing file in the repository because the old file INTERPOLATION.R is not
removed or renamed. Fixed by moving `interpolation.R` to another folder and then
bringing it back.
* Next time, instead of renaming a file try `Save As`.
* Tag 0.0.0.9007, 9008 deleted.


## 20170605 9006
* complete low level tests adding test_that
* tried to use subfolders under testthat bu was not succesful
* rename tests to be able to group them later. Low level tests now have a tag LL.
* change name and references of file INTERPOLATION.R to lowercase.
* rename data file used in tests. Start with `data`.


## 20170604 0.0.0.9003
* running OK
* rename get_extdataDir
* add getDefaultDataContainerName
* new test is_checking_package
* remove warnings in settings.R


## 20170604 0.0.0.9002
* Implemented a way to capture if we are in build package mode using a new function is_checking_package.
* added a bunch of small tests for testing paths.
* change logical function to something like this: is_xxx_yyy(). Example: 
    * is_checking_package
    * is_saved_session
* can copy a HDF5 data container in "local" mode. Similar to "project". 
* can check if the user has already a data comtainer so it is not overwritten,


## 20170531 `rPetroleum` package
* Found problem with rhdf5 which did not allow to build the package. Problem is with lack of declaration as S3 method. Found solution in forums. Issue is known. Fix is to manually edit NAMESPACE and add an `import(rhdf5)`. 
* For the moment using new functions to create temporary HDF5 files with `setHDF5DumpFile` and `getHDF5DumpFile`. This creates and saves the `h5` file somewhere under the user folder. Later will have to implement a way to copy or of creating the first `h5` file in the user folder. `./inst/extdata` perhaps?
* Two vignettes running. Examples `C13` and `C44`.
* Only three precarious unit tests. Need to test more and improve the coverage.
* No sub folders under `inst` yet.
* New scripts under `./R`: 
  * `settings.R `
  * `hdf5.R`
