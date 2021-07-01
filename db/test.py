from django.http import HttpResponse
import json
MY_MSG={
   0 : 'where',
   1 : 'and'
}
majorID = "a"
majorName = "b"
majorAddress = "c"
majorResp = None
schoolID = "q"
sql = "delete from 'major'"
flag = 0
attributes = {
'majorID' : majorID,
'majorName' : majorName,
'majorAddress' : majorAddress,
'majorResp' : majorResp,
'schoolID' : schoolID
   }
for key,value in attributes.items():
   if value != None:
      my_msg = MY_MSG[flag]
      flag = 1
      sql = "{} {} {} == {}".format(sql,my_msg,key,'"' + value + '"')
print(sql)