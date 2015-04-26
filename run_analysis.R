# Setup
setwd("/Users/knutk/Dropbox/Classes/DataScience/CleaningData/ProgAssign1/")
require(dplyr)

# Load the data from the test and learn dataset, and merge with the subject id so we have a identifier
# Test dataset
test <- read.table("data/test/X_test.txt")
activity <- read.table("data/test/y_test.txt")
colnames(activity) <- "activity_id"
subjectId <- read.table("data/test/subject_test.txt")
colnames(subjectId) <- "subject_id"
testdata <- cbind(subjectId, activity, test)
remove("test", "activity", "subjectId")

# Train dataset
train <- read.table("data/train/X_train.txt")
subjectId <- read.table("data/train/subject_train.txt")
colnames(subjectId) <- "subject_id"
activity <- read.table("data/train/y_train.txt")
colnames(activity) <- "activity_id"
traindata <- cbind(subjectId, activity, train)
remove("train", "subjectId", "activity")

# Merge the two datasets
data <- rbind(testdata, traindata)

# Get the measurements on mean and std
features <- read.table("data/features.txt")
idx <- grep("mean\\(\\)|std\\(\\)", features$V2)
dataIdx <- c(c(1, 2), idx + 2) # Adjust for labels and ids

# Use the indicies to extract the columns that we are interested in
data <- data[, dataIdx]

# Set colnames using the feature file
names(data) <- c("subject_id", "activity_id", gsub("\\(\\)", "", features[idx, 2]))
names(data) <- gsub("-", "", names(data))

# Make a new variable with the activity labels
activityLabels <- read.table("data/activity_labels.txt")
labels <- tolower(activityLabels[, 2])
naming <- function(num) {
  labels[num]
}
data <- transform(data, activity_desc = naming(activity_id))

# Make a new dataset with means for each variable for each subect
by_id <- group_by(data, subject_id, activity_id)
meandata <- summarise_each(by_id, funs(mean))

# Export the data
write.table(meandata, file="output.txt", row.name=FALSE)


