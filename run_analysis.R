
#The function "verify_and_install" check if a package is installed and it installs if not installed
verify_and_install<-function(name_package)
{
  if(name_package %in% rownames(installed.packages())==FALSE)
  {install.packages(name_package)}
}

verify_and_install("dplyr")    
verify_and_install("reshape2")


library(dplyr)
library(reshape2)


#read the test data 
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
      y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
      x_test <- read.table("UCI HAR Dataset/test/X_test.txt")

#read and concatenate the test file from "Inertial Signals" directory      
         cale <- "UCI HAR Dataset/test/Inertial Signals"
            f <- list.files(cale)
        readf <- function(x) read.table(paste0(cale,"/",x))
       lFiles <- lapply(f,readf)
fInertialTest <- bind_rows(lFiles)

#concatenate all test dataframe 
     testData <- cbind(subject_test, y_test, x_test, fInertialTest)

#read the train data      
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
      y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
      x_train <- read.table("UCI HAR Dataset/train/X_train.txt")

#read and concatenate the train file from "Inertial Signals" directory   
          cale <- "UCI HAR Dataset/train/Inertial Signals"
             f <- list.files(cale)
         readf <- function(x) read.table(paste0(cale,"/",x))
        lFiles <- lapply(f,readf)
fInertialTrain <- bind_rows(lFiles)
     trainData <- cbind(subject_train, y_train, x_train, fInertialTrain)

#1. Merge the training and test sets to create one data set
concatData <- rbind(testData, trainData)

# remove temporar variables
rm(subject_test)
rm(y_test)
rm(x_test)
rm(subject_train)
rm(y_train)
rm(x_train)
rm(cale)
rm(f)
rm(readf)
rm(lFiles)
rm(fInertialTest)
rm(testData)
rm(fInertialTrain)
rm(trainData)



# 2) extract only the measurements on the mean and standard deviation for each measurement

# read in the features
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)

#remove hyphens and parentheses from features$V2
#create a new vector (named nameCol) adding to features$V2 the vector c("idSubject","idActivity")
nameCol <- append(c("idSubject","idActivity"), make.names(features$V2, unique=TRUE), after=2)

# change the position 1 up to length(nameCol) from names(concatData) with the vector nameCol
names(concatData)[1:length(nameCol)] <- nameCol

#create a new data set with the columns which contains the string ".mean." and ".std."
#also I keep in this data set the columns idSubject si idActivity
filterData <- concatData %>%
              select(idSubject, idActivity, contains(".mean."), contains(".std."))

# remove temporar variables
rm(features)
rm(nameCol)



#3) use descriptive activity names to name the activites in the data set

#read the activity labels
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
   label <- activity[,2]

#create a new data.frame named activityData adding 
#the column Activity and removing the column idActivity
#the column "Activity" contains the activities that correspond to each idActivity  
#I kept the other columns unchanged   
activityData <- filterData %>% 
                mutate(Activity=label[idActivity]) %>%
                select(idSubject,-idActivity,Activity,3:ncol(filterData)) 

# remove temporar variables              
rm(activity)
rm(label)

# 4) appropriately label the data set with descriptive variable names
names(activityData) <- gsub( "Mag", "Magnitude", names(activityData))
names(activityData) <- gsub("Acc", "Acceleration", names(activityData))
names(activityData) <- gsub("Gyro", "AngularVelocity", names(activityData))
names(activityData) <- gsub("BodyBody", "Body", names(activityData))
names(activityData) <- gsub("\\.mean",".Mean", names(activityData))
names(activityData) <- gsub("\\.std",".Std", names(activityData))
names(activityData) <- gsub("^f","FrequencyDomain_", names(activityData))
names(activityData) <- gsub("^t","TimeDomain_", names(activityData))
names(activityData) <- gsub("X$","_on_X", names(activityData))
names(activityData) <- gsub("Y$","_on_Y", names(activityData))
names(activityData) <- gsub("Z$","_on_Z", names(activityData))

#if x contains ".Mean"(or ".Std) remove from x ".Mean"(or ".Std) and
#add "Mean_"(or "Std_) in front of x. Return this new string
#if x doesn't contains ".Mean"(or ".Std) return x
prepare<-function(x)
{
  if(length(grep(".Mean", x))!=0)
  {return(paste0("Mean_",gsub(".Mean", "",x)))}
  
  if(length(grep(".Std", x))!=0)
  {return(paste0("Std_",gsub(".Std", "",x)))}
  
  return(x)
}

f <- names(activityData)

#apply prepare function for vector names(activityData)
names(activityData) <- sapply(f, prepare) 

#remove from names(activityData) the string ".."
names(activityData) <- gsub("[..]","", names(activityData))

# remove temporar variable f
rm(f)


#5) From the data set in step 4, creates a second, 
#independent tidy data set with the average of each variable for 
#each activity and each subject.

#tidy date set is created in the following steps:
#- with the melt function transforms data from activityData from wide format in long format
#- group of the new data after idSubject, Activity and  variable
#- compute mean for each group (with summarise)
#- with the dcast function transform the new data from long format in wide format
#- sort the last data frame after idSubject and Activity

tidy_data <- melt(activityData, id.vars =c("idSubject", "Activity")) %>%
             group_by(idSubject, Activity, variable) %>%
             summarise(mean=mean(value)) %>%
             dcast(idSubject + Activity ~ variable, value.var="mean") %>%
             arrange(idSubject, Activity)


# write the tidy data set to a file for project submission
write.table(tidy_data, "tidy_data_set.txt", row.names=FALSE)


#remove from memomory all variables
rm(concatData)
rm(activityData)
rm(filterData)
rm(tidy_data)
