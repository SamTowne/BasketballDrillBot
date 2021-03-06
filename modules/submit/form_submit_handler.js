//TODO: output api gateway endpoint and insert here so it is dynamic at app standup
var post_url = "https://d7c1ezk0rk.execute-api.us-east-1.amazonaws.com/si/submit"

function onFormSubmit(e) {

  console.log('form submitted');

  // Calculate Date and Time in YYYY-MM-DD HH:MM:SS format
  let date_ob = new Date();
  let day = ("0" + date_ob.getDate()).slice(-2);
  let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
  let year = date_ob.getFullYear();
  let hours = date_ob.getHours();
  let minutes = date_ob.getMinutes();
  let seconds = date_ob.getSeconds();

  var date = year + "-" + month + "-" + day;
  var time = hours + ":" + minutes + ":" + seconds;

  var form = FormApp.getActiveForm();
  var allResponses = form.getResponses();
  var latestResponse = allResponses[allResponses.length - 1];
  var response = latestResponse.getItemResponses();

  //shots made from each position in the shooting drill, and the temperature
  var spot_1 = response[0].getResponse();
  var spot_2 = response[1].getResponse();
  var spot_3 = response[2].getResponse();
  var spot_4 = response[3].getResponse();
  var spot_5 = response[4].getResponse();
  var spot_6 = response[5].getResponse();
  var spot_7 = response[6].getResponse();
  var spot_8 = response[7].getResponse();
  var spot_9 = response[8].getResponse();
  var spot_10 = response[9].getResponse();
  var spot_11 = response[10].getResponse();
  var temp = response[11].getResponse();

  var headers = {
    "Content-Type": "application/json",
  };

  var options = {
    "method": "post",
    "headers": headers,
    "payload": JSON.stringify(
      {
        "spot_1":spot_1,
        "spot_2":spot_2,
        "spot_3":spot_3,
        "spot_4":spot_4,
        "spot_5":spot_5,
        "spot_6":spot_6,
        "spot_7":spot_7,
        "spot_8":spot_8,
        "spot_9":spot_9,
        "spot_10":spot_10,
        "spot_11":spot_11,
        "temp":temp,
        "date":date,
        "time":time,
      }
    )
  };

  UrlFetchApp.fetch(post_url, options)

};