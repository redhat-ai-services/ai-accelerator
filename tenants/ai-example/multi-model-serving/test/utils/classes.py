import yaml
import os


dir_path = os.path.dirname(os.path.realpath(__file__))

with open(os.path.join(dir_path, 'coco.yaml'), 'r') as f:
    data = yaml.safe_load(f)

coco_classes = [data['names'][i] for i in data['names']]
