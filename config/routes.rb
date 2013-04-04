Donabe::Application.routes.draw do

  scope ":tenant_id" do
    resources :containers do
      get 'deploy', :on => :member
      resources :routers
      resources :VMs
      resources :embedded_containers do
        resources :connected_routers
        resources :connected_vms
      end
    end
    match 'deployed_containers/:id/destroy_deployed' => 'containers#destroy_deployed_REST'
    resources 'deployed_containers'
  end

  match 'login' => 'logins#index', :via => :get
  match 'login' => 'logins#create', :via => :post
  match 'logout' => 'logins#destroy', :via => :get
  match 'switch' => 'logins#switch_tenant', :via => :post
  match 'tenants' => 'logins#get_tenants', :via => :get
  match 'current' => 'logins#current_tenant', :via => :get

  root :to => 'logins#index'
end
