from django.contrib import admin
from containers.models import Container, Router, Network, Vm, EmbeddedContainer, Endpoint

class RouterInLine(admin.StackedInline):
	model = Router
	extra = 0

class NetworkInLine(admin.StackedInline):
	model = Network
	extra = 0

class VmInLine(admin.StackedInline):
	model = Vm
	extra = 0

class EmbeddedContainerInLine(admin.StackedInline):
	model = EmbeddedContainer
	extra = 0

class EndpointInLine(admin.StackedInline):
	model = Endpoint
	extra = 0

class ContainerAdmin(admin.ModelAdmin):
	fields = ['name']
	inlines = [RouterInLine,NetworkInLine,VmInLine,EmbeddedContainerInLine,EndpointInLine]
	search_fields = ['name']

admin.site.register(Container, ContainerAdmin)
admin.site.register(Router)
admin.site.register(Network)
admin.site.register(Vm)
admin.site.register(EmbeddedContainer)
admin.site.register(Endpoint)
