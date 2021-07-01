majorID = mydata['majorID']
majorName = mydata['majorName']
majorAddress = mydata['majorAddress']
majorResp = mydata['majorResp']
schoolID = ""
mylist = [majorID,majorName,majorAddress,majorResp,schoolID]
for i in mylist:
   if i == "":
      i = "NULL"
sql = "insert into Major('majorID','majorName','majorAddress','majorResp','schoolID')"
sql = sql + " values(\'{}\'，\'{}\',\'{}\',\'{}\',\'{}\')".format(majorID,majorName,majorAddress,majorResp,schoolID)