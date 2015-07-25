# Readme.md 

The project use data from "Human Activity Recognition Using Smart Phones" project.

"Human Activity Recognition Using Smart Phones" project can be found at following location:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones (1)

## How the program run_analysis.R works
The program uses as input the data from the **UCI Har Dataset** directory. This data are imported in R and transformed in a tidy data set.

1. Bringing data in r<Enter>
      + import the files **subject_test.txt, y_test.txt, X_test.txt** using read.table
      + import and concatenate the test file from "Inertial Signals" directory  
      + combine this dateframe (using cbind) to create a dataframe named testData
      + import the files **subject_train.txt, y_train.txt, X_train.txt** using read.table
      + import and concatenate the train file from "Inertial Signals" directory  
      + combine this dateframe (using cbind) to create a dataframe named trainData
      
2. Merge the training and test sets to create one data set<Enter>
      + combine trainData and testData in one dataframe (named concatData) using rbind
      
3. Extract only the measurements on the mean and standard deviation for each measurement<Enter>
      + import the files **features.txt** using read.table in dataframe features
      + the first column from concatData is named idSubject
      + the second column from concatData is named idActivity
      + replace hyphens and parentheses (from column 2 of features) with periods.
      + the columns 3 up to (number of row of **features.txt**) from concatData are named with the values of column 2 of features
      + using dplyr create a new dataframe (named filterData) with columns "idSubject", "idActivity" and all columns from concatData which contains the string ".mean." (or ".std."). 
4. Use descriptive activity names to name the activites in the data set<Enter>
      + import the files **activity_labels.txt** using read.table in dataframe activity
      + save the column 2 of activity in label variable
      + using dplyr create a new dataframe (named activityData) adding the column Activity and removing the column idActivity (the column "Activity" contains the activities that correspond to each idActivity). I kept the rest of columns from concatData unchanged. The values from Acivity are computed using Activity=label[idActivity].
5. Appropriately label the data set with descriptive variable names<Enter>
      + replace some strings from names(activityData) with other values (using gsub). For example
      gsub( "Mag", "Magnitude", names(activityData)) replace "Mag" with "Magnitude" in the vector names(activityData). 
      + created the function **prepare** (see run_analysis.R)
      + remove (".Mean" or ".Std") and adding ("Mean_" or "Std_") in front of each element of vector    names(activityData) which contains (".Mean" or ".Std") using functions **sapply** and **prepare** 
      + remove ".." from names(activityData) using gsub R function
 6. From the data set in step 5, creates a second, independent tidy data set with the average of each variable for each activity and each subject. Tidy date set is created in the following steps:<Enter>  
      + with the melt function transforms data from activityData from wide format in long format
      + group of the new data after idSubject, Activity and variable
      + compute mean for each group (with summarise)
      + with the dcast function transform the new data from long format in wide format
      + sort the last data frame after idSubject and Activity



## How to run run_analysis.R

Before you run "run_analysis.R" you have to follow next steps:

  - download and unzip the file from location (1)
  - set the working directory (using setwd) to the folder where you unziped the above file.

After that you can load an run "run_analysis.R"	from R (or RStudio).