
# Reproduce RAP Results Pipeline


This repository contains all analysis scripts to reproduce the reported findings and figures. The corresponding data is stored at [the corresponding OSF repository](https://www.dummylinkforosfrepo.com). 


## General structure 


The analysis pipelines are separated for the pilot and main study, indicated by the prefix `RAP_Pilot_` or `RAP_Main_`. 

Moreover, the scripts are enumerated to ensure the correct order of analysis steps. Nonetheless, note that you can also access a single analysis step directly (e.g. `RAP_Main_4_`) and execute it without running all preceding steps before, because the data folder also contains intermediate data. 

By default, running an analysis step will overwrite the presaved data. In each script, you can therefore change output folders.


## Step by step: What do I need to do before I can start?



### 1. Check general requirements


#### 1.1. Matlab

*Matlab R2020a*

```
MATLAB Version: 9.8.0.1323502 (R2020a)
Operating System: Linux 4.4.0-186-generic #216-Ubuntu SMP Wed Jul 1 05:34:05 UTC 2020 x86_64
Java Version: Java 1.8.0_202-b08 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
```

#### 1.2. R

*R 3.6.1* & *RStudio 1.2.1335*

```
platform        x86_64-w64-mingw32
arch	        x86_64
os              mingw32
system	        x86_64, mingw32
status	
major	        3
minor	        6.1
year	        2019
month	        07
day             05
svn rev	        76782
language        R
version.string	R version 3.6.1 (2019-07-05)
nickname        Action of the Toes
```


### 2. Get the data


Please make sure that you download the data from [OSF](https://osf.io/de4bu/).


### 3. Download MemToolbox & helper functions


Download [MemToolbox](http://visionlab.github.io/MemToolbox/) if necessary. If you haven't done yet, please download at least the `helper_fun` folder in this repository.


### 4. Change paths


In R scripts, please change `study_path = '...'` (always in the 4th code chunk) according to your download folder. For script `RAP_Pilot_2`, please also specify `help_fun_path = "..."` and set it to the folder in which you have downloaded it. 


In Matlab scripts, please adjust `study_folder = "..."` and `memtoolbox_folder = "..." ` accordingly. You can always find it in the first lines of code. 


### 5. Automatic installations


In R, you don't need to download or install packages by hand, as the first lines of code will do this for you automatically. Hence, by default there will be an installation of the package `devtools`, which is required to install the packages `rmTools`(contains some required custom functions) and `envRAP`(installs all dependencies required for the RAP analyses).

**Note:** In general, I recommend to run every script with the "Knit" command (in the panel above the script, in RStudio), which will provide you with a detailed html report for each analysis step. Nonetheless, **before you run the very first script**, please execute the second code chunk once by hand (**not** with knit, but with the "play" button in the right upper corner instead). When executed for the first time, there will be a dialog in the R console asking you whether you want to install and/or update certain packages depending on your current installation (if you don't see it after pressing the play button, please double-check whether you are in the tab "R Markdown" instead of "Console" and switch to the latter). To guarantee flawlessly running scripts, please update all scripts which are behind the requested minimum version **and** accept to install the `envRAP`and `rmTools` R packages. Afterwards, you can proceed with executing each R script with "Knit".

```
# installs devtools if not found on machine, needed to install packages from github
if(!("devtools" %in% installed.packages()[,"Package"])) install.packages('devtools')
library('devtools')
# will install required dependencies for RAP analysis
devtools::install_github('remichel/envRAP') 
# initialize all required packages
rmTools::libraries(ggplot2, reshape2, pracma, Rmisc, circular, scales, R.matlab, dplyr, stats, lattice, car, rmTools, knitr, kableExtra) 
```


### 6. Adjust specifications


Before running a script, you can adjust the specifications in the 3rd code chunk of each R script (or the first lines of code in Matlab scripts). See an example for an R script specification chunk below:

```
subject_list        = c(1:10,12:15)
session_list        = c(1:9)
n_soas              = 20
n_perm              = 10000 # number of permutations
do_setseed          = T     # set to T if you want to reproduce the findings
do_createdirs       = T     # if T, script checks for directories and creates them if necessary
do_save             = T     # T if you want to save files. might overwrite existing datafiles
do_mm               = T     # export matlab files for mixture model analysis?
do_withinval        = T     # preproc for analysis by validity (valid vs invalid)
do_acrossval        = T     # preproc for analysis across validity (merge valid and invalid) 
exclude_1st_session = T     # exclude practice session? 
```


### 7. Start


Now you should be able to start. If you encounter any kind of problem, feel free to contact @remichel for help.

