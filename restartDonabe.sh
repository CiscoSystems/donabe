#!/bin/bash

rake db:drop
rake db:create
rake db:migrate

rails server -p 3001
