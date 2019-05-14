#!/usr/bin/env python
from jinja2 import Environment, FileSystemLoader
import json

with open('validators.json') as json_file:
    template_data = json.load(json_file)

file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

template = env.get_template('main.tf')
output = template.render(template_data)

with open('main.tf', 'w') as outfile:
    outfile.write(output)
