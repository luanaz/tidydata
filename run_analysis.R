library(dplyr)
library(tidyr)

#STEP 1: Merges the training and the test sets to create one data set

#Read features as col.names in X_train and X_test
features <- read.table("./features.txt", stringsAsFactors = FALSE)
str(features) #for check

subject_train <- read.table("./train/subject_train.txt")
X_train <- read.table("./train/X_train.txt", col.names = features$V2)
Y_train <- read.table("./train/Y_train.txt")
dim(subject_train); dim(X_train); dim(Y_train) #for check
str(subject_train); str(X_train); str(Y_train) #for check
names(subject_train)[names(subject_train) == "V1"] = "subjects"
names(Y_train)[names(Y_train) == "V1"] = "activities"
#Combind subjects and activities into data_train
data_train <- cbind(subject_train, Y_train, X_train) 

subject_test <- read.table("./test/subject_test.txt")
X_test <- read.table("./test/X_test.txt", col.names = features$V2)
Y_test <- read.table("./test/Y_test.txt")
dim(subject_test); dim(X_test); dim(Y_test) #for check
str(subject_test); str(X_test); str(Y_test) #for check
names(subject_test)[names(subject_test) == "V1"] = "subjects"
names(Y_test)[names(Y_test) == "V1"] = "activities"
#Combind subjects and activities into data_test
data_test <- cbind(subject_test, Y_test, X_test) 

#merge the train and the test data
data_merged <- rbind(data_train, data_test)

#release memory
rm(subject_train); rm(subject_test)
rm(X_train); rm(X_test)
rm(Y_train); rm(Y_test)
rm(data_train); rm(data_test)
gc()

#STEP 2: Extracts only the measurements on the mean and standard deviation for each measurement
col_mean <- grep("mean()", features$V2, fixed = TRUE)
data_mean <- data_merged[, col_mean + 2]
col_std <- grep("std()", features$V2, fixed = TRUE)
data_std <- data_merged[, col_std + 2]
data_mean_std <- cbind(data_merged[, c(1, 2)], data_mean, data_std)

#STEP 3: Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table("./activity_labels.txt", stringsAsFactors = FALSE)
names(activity_labels) <- c("activities", "activity_names")
data_activity_names <- select(merge(data_mean_std, activity_labels, by = "activities"), -activities)

#STEP 4: Labels the data set with descriptive variable names
data_activity_names$row <- 1:nrow(data_activity_names)
data_labels <- gather(data_activity_names, coordinates, values, -subjects, -activity_names, -row) %>% spread(activity_names, values) %>% select(-row)

#STEP 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject
data_tidy <- aggregate(data_labels, by = list(data_labels$subjects), FUN = mean, na.rm = TRUE)[, -c(1, 3)]

#Create a txt file containing the data set in step 5
write.table(data_tidy, "data_tidy.txt", row.names = FALSE)
