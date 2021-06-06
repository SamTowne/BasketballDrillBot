# Shooting Insights

Shooting Insights provides basketball shooting analytics. The data is obtained from three point shooting drill practice sessions. The primary data points are shots made and the temperature during the drill. 

## App Structure
The Application consists of 4 parts.

### 1. Bootstrap
Bootstrap builds the app. It creates cloud services and tells them to play nicely with one another. Terraform is the primary tool used for this.

### 2. Collection
Collection feeds data into the app. The entry point is a Google form. The user inputs the results of their shooting drill. This includes the shots made from each location and the current temperature. Submission of the form kicks off a serverless app flow to store the data in AWS S3 for further processing.

### 3. Processing
The collection step results in raw json objects stored in s3. Processing preps that data for use by analytics services.

### 4. Analytics
Analytics receives the processed data and provides some pretty visualizations.

## Using the app

1. Attempt 10 shots from 11 locations and submit the results via the Google Form.

    ![half court shooting locations](img/half_court.png)

2. Form submission triggers the collection app flow.

 - TODO: create a diagram of a form submission 
 - Google Form Submit => Google Trigger => Google Apps Script HTTP POST (node.js) => Amazon API Gateway => AWS Lambda (python)
