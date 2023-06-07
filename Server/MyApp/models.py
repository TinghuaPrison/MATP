from django.db import models


class User(models.Model):
    username = models.CharField(max_length=30, unique=True)
    password = models.CharField(max_length=30)
    avatar = models.CharField(max_length=100)
    bio = models.TextField()
    c_time = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username


class Follow(models.Model):
    follower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='follower')
    followee = models.ForeignKey(User, on_delete=models.CASCADE, related_name='followee')


class Block(models.Model):
    blocker = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blocker')
    blocked = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blocked')


class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sender')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='receiver')
    content = models.TextField()
    c_time = models.DateTimeField(auto_now_add=True)


class Session(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='session_user')
    target = models.ForeignKey(User, on_delete=models.CASCADE, related_name='session_target')
    last_message = models.TextField()
    message_cnt = models.IntegerField(default=0)
    message_not_checked = models.IntegerField(default=0)
    c_time = models.DateTimeField(auto_now_add=True)


class Moment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='moment_user')
    type = models.CharField(max_length=10, default='未分类')
    content = models.TextField(default=' ')
    media = models.CharField(max_length=100, default='null')
    location = models.CharField(max_length=100, default='null')
    likes_count = models.IntegerField(default=0)
    favorites_count = models.IntegerField(default=0)
    comments_count = models.IntegerField(default=0)
    c_time = models.DateTimeField(auto_now_add=True)


class Like(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='like_user')
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, related_name='likes')


class Favorite(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_user')
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, related_name='favorites')


class Comment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comment_user')
    moment = models.ForeignKey(Moment, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    c_time = models.DateTimeField(auto_now_add=True)


class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notification_user')
    title = models.CharField(max_length=30)
    content = models.TextField()
    c_time = models.DateTimeField(auto_now_add=True)




