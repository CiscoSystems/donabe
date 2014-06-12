from django.db import models

class Container(models.Model):
	name = models.CharField(max_length=200)
	def __unicode__(self):
		return self.name

class Router(models.Model):
	container = models.ForeignKey(Container)
	name = models.CharField(max_length=200)
	temp_id = models.CharField(max_length=200)
	endpoint = models.BooleanField(default=False)
	def __unicode__(self):
		return self.name

class Vm(models.Model):
	container = models.ForeignKey(Container)
	name = models.CharField(max_length=200)
	temp_id = models.CharField(max_length=200)
	image_name = models.CharField(max_length=200)
	image_id = models.CharField(max_length=200)
	flavor = models.CharField(max_length=200)
	endpoint = models.BooleanField(default=False)
	def __unicode__(self):
		return self.name

class Network(models.Model):
	container = models.ForeignKey(Container)
	router = models.ForeignKey(Router)
	vms = models.ManyToManyField(Vm)
	name = models.CharField(max_length=200)
	temp_id = models.CharField(max_length=200)
	cidr = models.CharField(max_length=200)
	endpoint = models.BooleanField(default=False)
	def __unicode__(self):
		return self.name

class EmbeddedContainer(models.Model):
	container = models.ForeignKey(Container)
	temp_id = models.CharField(max_length=200)
	def __unicode__(self):
		return self.id

class Endpoint(models.Model):
	container = models.ForeignKey(Container)
	embedded_container = models.ForeignKey(EmbeddedContainer)
	endpoint_id = models.CharField(max_length=200)
	connected_id = models.CharField(max_length=200)
	def __unicode__(self):
		return self.id
