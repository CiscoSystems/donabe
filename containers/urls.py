from django.conf.urls import patterns, url

from containers import views

urlpatterns = patterns('',
	url(r'^$', views.index, name='index')
)
