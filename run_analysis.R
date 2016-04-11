# in the following script, different steps will be numbered based of groups of functionality
# librarys will go within scripts to be easier for reader to associate library with command
#1- download file from griven url and unzip it to cleandataAssignment folder
download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
              , destfile = "./cleandataAssignment.zip")
unzip(zipfile = "./cleandataAssignment.zip",exdir = "./cleandataAssignment")

#2- read common files {activity_labels , features}
#activity_labels to be assigned as levels for final data frame
# and features to extract column names for that data set
library(reader)
columnsNames=read.delim(file="./cleandataAssignment/UCI HAR Dataset/features.txt",sep = " ",header = F)
activityLabelDataFrame=read.delim(file="./cleandataAssignment/UCI HAR Dataset/activity_labels.txt",sep = " ",header = F)

#3- read test folder small files {subject_test.txt     ,y_test.txt } thos will be subjects and activities
subjecttestDataFrame=read.delim(file="./cleandataAssignment/UCI HAR Dataset/test/subject_test.txt",sep = " ",header = F)
testActivities=read.delim(file="./cleandataAssignment/UCI HAR Dataset/test/y_test.txt",sep = " ",header = F)
#4- generate vector of widths of the file columns,  there are 561 columns with 16 digit width for each including the spaces
columnWidths=vector(length = 561)
columnWidths[1:561]=16
#5- read the large file that contains the core test data  { x_test.txt} as a fixed width formatted file
testDataFrame=read.fwf(file = "./cleandataAssignment/UCI HAR Dataset/test/X_test.txt", widths = columnWidths,header = F)
#6- combine the 3 data frames
testDataFrame=cbind(subjecttestDataFrame$V1,testDataFrame)
testDataFrame=cbind(testDataFrame,testActivities)

# ####  applying similar steps from 3, 5  to get train data frame
subjecttrainDataFrame=read.delim(file="./cleandataAssignment/UCI HAR Dataset/train/subject_train.txt",sep = " ",header = F)
trainActivities=read.delim(file="./cleandataAssignment/UCI HAR Dataset/train/y_train.txt",sep = " ",header = F)
#  5- read the large file that contains the core train data  { x_train.txt} as a fixed width formatted file
trainDataFrame=read.fwf(file = "./cleandataAssignment/UCI HAR Dataset/train/X_train.txt", widths = columnWidths,header = F)
#  6- combine the 3 data frames
trainDataFrame=cbind(subjecttrainDataFrame$V1,trainDataFrame)
trainDataFrame=cbind(trainDataFrame,trainActivities)

#7- getting the column names and trimming spaces, adding subject at start, activity at the end
library(stringr)
cleanColumnNames=str_trim(columnsNames$V2)
cleanColumnNames=gsub("-","",cleanColumnNames)
cleanColumnNames=c("subject",cleanColumnNames, "activity")  
stdAndMeanColumnNames=grep(pattern="^.*(std\\(\\)|mean\\(\\)).*$",ignore.case = T,cleanColumnNames,value=T)
stdAndMeanColumnNames=c("subject",stdAndMeanColumnNames, "activity") 
#8- union test and train data frames 
names(testDataFrame)=cleanColumnNames
names(trainDataFrame)=cleanColumnNames
unionDataFrame=rbind(testDataFrame,trainDataFrame)
#9- assigning levels to factor last column in the data frame.
levels(unionDataFrame[,563])=activityLabelDataFrame$V2
names(unionDataFrame)=cleanColumnNames

#10- get the standard deviation and mean columns only
stdAndmeanDataframe=unionDataFrame[,stdAndMeanColumnNames]

# 11- group by 
groups1=group_by(stdAndmeanDataframe,subject,activity)
result=lapply(groups1,mean)
result2=result[][2:68]
write.csv(result2,"./result.csv")
