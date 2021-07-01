from django.shortcuts import render,HttpResponse
import json

@csrf_exempt
class SignUp(APIView):
    def post(self, request):
        responses = {'msg':'','state':''}
        if request.method =="POST":
            try:
                mydata = json.loads(request.body)
                majorID = mydata['majorID']
                '''majorName = mydata['majorName']
                majorAddress = mydata['majorAddress']
                majorResp = mydata['majorResp']
                schoolID = mydata['schoolID']
                insert_data = (majorID,majorName,majorAddress,majorResp,schoolID)
                print(insert_data)'''
                responses['msg'] = majorID
                responses['state'] = '003'
            except:
                responses['msg'] = '未知错误，请重试！'
                responses['state'] = '003'
        return JsonResponse(responses)

class Login(APIView):
    def post(self, request):
        responses = {'msg':'','state':'000','token':'None'}
        if request.method == "POST":
            try:
                username = request.data.get('username')
                password = request.data.get('password')
                user = models.User.objects.filter(username=username, password=password).first()
                if not user:
                    responses['msg'] = '用户名或密码错误'
                    responses['state'] = '004'
                else:
                    token=hashlib.md5(bytes(username+str(time.localtime()), encoding='utf-8')).hexdigest()
                    models.UserToken.objects.update_or_create(user=username, token=token)
                    responses['token'] = token
                    responses['msg'] = '登录成功！'
                    responses['state'] = '005'
            except:
                responses['msg'] = '未知错误，请重试！' 
                responses['state'] = '006'
        return JsonResponse(responses)

MY_Festival = {
    '12-25':'圣诞节',
    '10-01':'国庆节',
    '01-01':'元旦'
}
class Festival(APIView):
    def post(self, request):
        responses = {'msg':'','state':''}
        if request.method == "POST":
            try:
                token = request.data.get('token')
                user_token = models.UserToken.objects.filter(token=token).first()
                if not user_token:
                    responses['msg']='未登录，请登录后重试'
                    responses['state']='007'
                    return JsonResponse(responses)
                else:
                    pass
            except:
                responses['msg'] = '未知错误，请重试'
                responses['state'] = '008'
                return JsonResponse(responses)
                    
            
            date = request.data.get('date')
            date_array = date.split('-')
            my_date = date_array[1] + '-' + date_array[2]
            try:
                if my_date == '01-01' or my_date == '10-01' or my_date == '12-25':
                    responses['msg'] = '查询成功'
                    responses['festival'] =   MY_Festival[my_date]
                    responses['state'] = '009'
                else:
                    responses = {}
            except:
                responses['msg'] = '未知错误，请重试'
                responses['state'] = '008'
        return JsonResponse(responses)
