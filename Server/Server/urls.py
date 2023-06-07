"""
URL configuration for Server project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

import MyApp.views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('user_register/', MyApp.views.user_register),
    path('user_login/', MyApp.views.user_login),
    path('edit_avatar/', MyApp.views.edit_avatar),
    path('edit_username/', MyApp.views.edit_username),
    path('edit_password/', MyApp.views.edit_password),
    path('edit_bio/', MyApp.views.edit_bio),
    path('get_all_users/', MyApp.views.get_all_users),
    path('get_user/', MyApp.views.get_user),
    path('follow/', MyApp.views.follow),
    path('unfollow/', MyApp.views.unfollow),
    path('get_followers/', MyApp.views.get_followers),
    path('get_followees/', MyApp.views.get_followees),
    path('block/', MyApp.views.block),
    path('unblock/', MyApp.views.unblock),
    path('get_blockers/', MyApp.views.get_blockers),
    path('get_blockeds/', MyApp.views.get_blockeds),
    path('send_message/', MyApp.views.send_message),
    path('start_session/', MyApp.views.start_session),
    path('get_sessions/', MyApp.views.get_sessions),
    path('post_moment/', MyApp.views.post_moment),
    path('get_moments/', MyApp.views.get_moments),
    path('like_moment/', MyApp.views.like_moment),
    path('unlike_moment/', MyApp.views.unlike_moment),
    path('get_like_moments/', MyApp.views.get_like_moments),
    path('get_moment_likes/', MyApp.views.get_moment_likes),
    path('favorite_moment/', MyApp.views.favorite_moment),
    path('unfavorite_moment/', MyApp.views.unfavorite_moment),
    path('get_favorite_moments/', MyApp.views.get_favorite_moments),
    path('get_moment_favorites/', MyApp.views.get_moment_favorites),
    path('comment_moment/', MyApp.views.comment_moment),
    path('get_comment_moments/', MyApp.views.get_comment_moments),
    path('get_moment_comments/', MyApp.views.get_moment_comments),
    path('post_notification/', MyApp.views.post_notification),
    path('get_notifications/', MyApp.views.get_notifications),
]
