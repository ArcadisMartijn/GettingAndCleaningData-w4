# Importing necessary libraries
library(readr)
library(plyr)

# Current working directory
cwd <- getwd()

## 1. Merges the training and the test sets to create one data set
# Files to proces
fileTrain <- file.path(cwd,"data", "train", "X_train.txt")
fileTest <- file.path(cwd,"data", "test", "X_test.txt")
fileCol <- file.path(cwd,"data","features.txt")

# Read files into datasets
dataTrain <- read_fwf(fileTrain, fwf_empty(fileTrain))
dataTest <- read_fwf(fileTest, fwf_empty(fileTest))
dataCol <- read_delim(fileCol,
                      delim = " ",
                      col_names = c("id", "varName"))

# Combine data into one dataset and specify column (variable) names
# This step is equal to point 4 of the assignment
dataMerge <- rbind(dataTrain, dataTest)
colnames(dataMerge) <- gsub("\\(|\\)", "", dataCol$varName)

# Make room in the memory by removing unused data
remove(dataTrain, dataTest, dataCol)

## 2. Extracts only the measurements on the mean and standard deviation for 
##    each measurement

# Select variables based on patterns
dataMain <- dataMerge[,grep("-mean[-|]|-std", colnames(dataMerge))]

# Make room in the memory by removing unused data
remove(dataMerge)

## 3. Uses descriptive activity names to name the activities in the data set

# Reading files into datasets
fileYTrain <- file.path(cwd,"data", "train", "Y_train.txt")
fileYTest <- file.path(cwd,"data", "test", "Y_test.txt")
fileYNames <- file.path(cwd,"data","activity_labels.txt")

dataYTrain <- read.table(fileYTrain)
dataYTest <- read.table(fileYTest)
dataYNames <- read.table(fileYNames)

# Combine activity type data into one dataset
dataYMerge <- data.frame(matrix(unlist(rbind(dataYTrain, dataYTest))))
colnames(dataYMerge) <- c("activity")

# Add the activity type number and descriptive name to the main dataset
dataMain <- cbind(dataMain, dataYMerge)
dataMain$activityName <- dataYNames[dataYMerge$activity,"V2"]

# Make room in the memory by removing unused data
remove(dataYTrain, dataYTest, dataYNames, dataYMerge)

## 4. Appropriately labels the data set with descriptive variable names.
## is combined above, in step 2.

## 5. From the data set in step 4, creates a second, independent tidy data set
##   with the average of each variable for each activity and each subject.

# Add subjects to merged dataset
# Reading files into datasets
fileSTrain <- file.path(cwd,"data", "train", "subject_train.txt")
fileSTest <- file.path(cwd,"data", "test", "subject_test.txt")

dataSTrain <- read.table(fileSTrain)
dataSTest <- read.table(fileSTest)

# Combine subject data into one dataset and add it to the main dataset
dataSMerge <- data.frame(matrix(unlist(rbind(dataSTrain, dataSTest))))
colnames(dataSMerge) <- c("subject")
dataMain <- cbind(dataMain, dataSMerge)

# Make room in the memory by removing unused data
remove(dataSTrain, dataSTest, dataSMerge)

# Generate a tidy dataset with the average of each variable for each activity
# and each subject
tidyresult <- ddply(dataMain, c("activityName", "subject"), numcolwise(mean))

# Write dataset to CWD in tabular format
write.table(tidyresult, 
            file = file.path(cwd, 'data', "tidyresult.txt"), 
            row.names = FALSE)
