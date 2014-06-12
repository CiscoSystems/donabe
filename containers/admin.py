from django.contrib import admin
from containers.models import Container, Router, Network, Vm, EmbeddedContainer, Endpoint

class RouterInLine(admin.StackedInline):
	model = Router
	extra = 1

class NetworkInLine(admin.StackedInline):
	model = Network
	extra = 1

class VmInLine(admin.StackedInline):
	model = Vm
	extra = 1

class EmbeddedContainerInLine(admin.StackedInline):
	model = EmbeddedContainer
	extra = 1

class EndpointInLine(admin.StackedInline):
	model = Endpoint
	extra = 1

class ContainerAdmin(admin.ModelAdmin):
	fields = ['name']
	inlines = [RouterInLine,NetworkInLine,VmInLine,EmbeddedContainerInLine,EndpointInLine]
	search_fields = ['name']

admin.site.register(Container, ContainerAdmin)
