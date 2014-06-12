from django.shortcuts import render

from containers.models import Container

def index(request):
	containers = Container.objects.all()
	context = {'containers': containers}
	return render(request, 'containers/index.json', context)
