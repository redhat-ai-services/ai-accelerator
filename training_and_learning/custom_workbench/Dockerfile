#This is the base image we'll be working from
FROM quay.io/mmurakam/workbenches:fraud-detection-v1.0.1  

# Copying custom packages
# The requirements.txt file contains additional package dependencies we want installed
COPY requirements.txt ./  

# Install packages and cleanup
# (all commands are chained to minimize layer size)
RUN echo "Installing softwares and packages" && \     
    pip install micropipenv && \
    # Install Python packages \
    micropipenv install && \
    rm -f ./requirements.txt

# Fix permissions to support pip in OpenShift environments \
RUN chmod -R g+w /opt/app-root/lib/python3.9/site-packages && \    
    fix-permissions /opt/app-root -P