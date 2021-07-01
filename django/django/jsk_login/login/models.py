from django.db import models

class User(models.Model):
    username = models.CharField(max_length=40, unique=True)
    password = models.CharField(max_length=40)
class UserToken(models.Model):
    user = models.CharField(max_length=40, unique=True)
    token = models.CharField(max_length=100)