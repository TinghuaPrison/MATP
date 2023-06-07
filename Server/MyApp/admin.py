from django.contrib import admin

# Register your models here.
from . import models


admin.site.register(models.User)
admin.site.register(models.Block)
admin.site.register(models.Like)
admin.site.register(models.Moment)
admin.site.register(models.Notification)
admin.site.register(models.Message)
admin.site.register(models.Favorite)
admin.site.register(models.Comment)
admin.site.register(models.Follow)
admin.site.register(models.Session)

