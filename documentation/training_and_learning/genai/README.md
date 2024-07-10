# GenAI on OCP
This tutorial relies heavily and uses this repository:
https://github.com/rh-aiservices-bu/llm-on-openshift


## Set up Cluster
Navigate to demo.redhat.com and order a __RHOAI on OCP on AWS with NVIDIA GPUs__ sandbox.
Wait for it to spin up and log in.

Since we'll be running a large size LLM and some other Apps, we'll need to increase our cluster size.
To do this, we'll change our MachineSets.
In the OpenShift Dashboard > Compute > MachineSets. 

Select one of the MachineSets and spin it down to zero by editing the Machine count.
![Edit Machine Count](./images/edit_machine_count.png "Edit Machine Count")

Then __Edit MachineSet__ to edit the yaml to change the Instance type.
You can view the different type of instances that we can use here (scroll down to Accelerated Computing):
https://aws.amazon.com/ec2/instance-types/ 

We've tested using __g5.2xlarge__ so we'll choose this one. Edit one of the MachineSet yaml to reflect this:
![instanceType Edit](./images/change_instance_type.png "Edit Machine Count yaml instance type")

Save and let it spin up. This can take some time. 
(In our testing, we only needed 1 MachineSet, so we removed/deleted the other MachineSet. Up to you if you want to have 1 MachineSet)

## Set up vLLM
We'll be using this repository to get the vLLM set up: https://github.com/rh-aiservices-bu/llm-on-openshift/tree/main/llm-servers/vllm
This repository uses and installs _Mistral-7B-Instruct-v0.2_ model and exposes it.
You can use the Automated install using GitOps (if installed) or using kustomize or manually.

<details>
<summary>Using kustomize to create manifests:</summary>

You can also use kustomize to apply all the manifests at once:
`kustomize build https://github.com/rh-aiservices-bu/llm-on-openshift.git/llm-servers/vllm/gitops | oc apply -f -`

This applies the pvc, service, route, and deployment in one command. Make sure you are in the correct namespace. Make sure to add your HuggingFace token to the deployment environment variable.

You can skip to testing the vLLM after this step
</details>

### Manually:
1. Create a new namespace named __vllm__.
`oc new-project vllm`

2. Create PVC, deployment, & service in __vllm__ namespace.

#### PVC: 
`oc apply -f https://raw.githubusercontent.com/rh-aiservices-bu/llm-on-openshift/main/llm-servers/vllm/gpu/gitops/pvc.yaml`

#### Service: 
`oc apply -f https://raw.githubusercontent.com/rh-aiservices-bu/llm-on-openshift/main/llm-servers/vllm/gpu/gitops/service.yaml`

#### Route: 
`oc apply -f https://raw.githubusercontent.com/rh-aiservices-bu/llm-on-openshift/main/llm-servers/vllm/gpu/gitops/route.yaml`

#### Deployment: 
For the deployment, we'll need to edit the __env variable: HUGGING_FACE_HUB_TOKEN__ with your hugging face token.

We need this use this token because the model we're using, _Mistral-7B-Instruct-v0.2_, is gated. You must be authenticated to access it. Navigate to https://huggingface.co/settings/tokens and create a new token and copy it for the environment variable.

![mistralhf](./images/mistralhf_login.png "mistralhf")


Download the __deployment.yaml__: https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/llm-servers/vllm/gpu/gitops/deployment.yaml#L52 and add your token.

![env hf token](./images/hf_hub_token.png "env hf token")

After you add the token to the environment variable, apply this deployment to the __vllm__ project.

Navigate to the deployment pod logs and wait for the startup to complete:
![vllm logs](./images/vllm_logs.png "vllm logs")



## Test vLLM

Navigate to the vllm route and add `/docs` to the end of it (https://vllm-vllm.apps.cluster-1.sandbox123.opentlc.com/docs) to open the openAPI web page to test the vLLM.

![api](./images/fastapi_vllm.png "vllm api")

You can try the API by using the `/v1/chat/completions` and using the "try it out" feature.

Sample request body (clear the request body and substitute with these):
```
{
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "messages": [
    {"role": "user", "content": "Who won the world series in 2020?"},
    {"role": "assistant", "content": "You are a helpful assistant. You speak like a pirate."}
  ]
}
```

<details>
<summary>Response</summary>
<code>
{
  "id": "cmpl-5fe57a4653e749189b912b404f9f64c8",
  "object": "chat.completion",
  "created": 1713544715,
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": " I be havin' me a bit of fun with me words, aye? But in serious talk, let me answer yarr question properly. The world series in 2020 was won by the Tampa Bay Rays. They claimed the championship title in Major League Baseball after defeating the Los Angeles Dodgers in six games. Now, prepare to be boarded by more knowledge, if ye be so inclined!"
      },
      "logprobs": null,
      "finish_reason": "stop",
      "stop_reason": null
    }
  ],
  "usage": {
    "prompt_tokens": 35,
    "total_tokens": 124,
    "completion_tokens": 89
  }
}
</code>
</details>

or


```
{
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "messages": [
    {"role": "user", "content": "How can I create a Data Science Connection"},
    {"role": "assistant", "content": "You are a helpful assistant."}
  ]
}
```

<details>
<summary>Response</summary>
<code>{
  "id": "cmpl-8f8eda2c5ef5465ab54f88bfc074c796",
  "object": "chat.completion",
  "created": 1713544308,
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": " I assume you mean \"how can I build a data science project or application\" rather than creating a physical connection like a cable or a network. Here are some general steps to build a data science project or application:\n\n1. Identify a problem or question: Determine what problem you want to solve or question you want to answer using data science. This could be anything from predicting customer churn to identifying fraudulent transactions.\n2. Collect and preprocess the data: Gather the relevant data for your problem and preprocess it to ensure it is in a usable format. This may involve cleaning, transforming, and aggregating data.\n3. Explore and analyze the data: Use data visualization and statistical techniques to explore the data and gain insights. This may involve identifying trends, patterns, and correlations.\n4. Build and train a model: Use machine learning algorithms or statistical models to build a predictive or descriptive model. This may involve selecting features, splitting the data into training and test sets, and tuning the model's hyperparameters.\n5. Evaluate the model: Evaluate the performance of the model using metrics such as accuracy, precision, recall, or F1 score. This will help you determine if the model is effective in solving your problem or answering your question.\n6. Deploy and monitor the model: Deploy the model into production and monitor its performance over time. This may involve integrating the model into an application, setting up alerts, or scheduling regular model re-training.\n7. Communicate and present the results: Communicate the results of your project to stakeholders, including data scientists, business analysts, and decision-makers. Use visualizations, dashboards, or reports to present the insights gained from the data."
      },
      "logprobs": null,
      "finish_reason": "stop",
      "stop_reason": null
    }
  ],
  "usage": {
    "prompt_tokens": 24,
    "total_tokens": 396,
    "completion_tokens": 372
  }
}
</code>
</details>

## Create Vector Database - PostgreSQL w/ vector extension

We're still using the examples from this repository:
https://github.com/rh-aiservices-bu/llm-on-openshift/tree/main/vector-databases/pgvector

Follow the instructions to install PostgreSQL. Make sure the vector extension is enabled.

## Combining everything together in RHOAI
Login to RHOAI and create a new Data Science Project.

Before creating a Data Science Project, navigate in the `RHOAI Dashboard > Settings > Accelerator profiles` and make sure the NVIDIA GPU is enabled.

Create a Data Science Project named `rag-demo` with a `Standard Data Science` Notebook image and either `Small` or `Medium` Container size. After the notebook is running, open and go into it.

Git clone the repo to pull down the files and examples:
https://github.com/rh-aiservices-bu/llm-on-openshift

Navigate to `examples/notebooks/langchain/` folder.

#### Ingest docs into vector db
Open `Langchain-PgVector-Ingest.ipynb` and run through the notebook. This will pull the RHOAI documents and ingest them into the psql vector database.

Make sure to edit the __CONNECTION_STRING__ with the correct username and password and service.
Example: `CONNECTION_STRING = "postgresql+psycopg://vectordb:vectordb@postgresql:5432/vectordb"`

(You can find this in the __01_db_secret.yaml__
 here: https://github.com/rh-aiservices-bu/llm-on-openshift/tree/main/vector-databases/pgvector)

 Open `Langchain-PgVector-Query.ipynb` and run through the notebook to query the docs in the db.

### vLLM with db and langchain
Open `RAG_with_sources_Langchain-vLLM-PgVector.ipynb` notebook and run through it.

Make sure to edit the __CONNECTION_STRING__ with the correct username and password and service and __CONNECTION_NAME__ with the correct folder/db.

```
CONNECTION_STRING = f"postgresql+psycopg://vectordb:vectordb@postgresql:5432/vectordb"
COLLECTION_NAME = f"rhoai-doc-2.6"
```

Make sure to edit the __INFERENCE_SERVER_URL__ with the vLLM inference route:
`INFERENCE_SERVER_URL = f"https://vllm-vllm.apps.cluster-8abcd.sandboxabc.opentlc.com/v1"`

The notebook goes through initializing the vector db connection, creating the query chain with a template, creating the LLM connection, and then combining them together.

It then goes through asking a question which then invokes the LLM with the information that is in the vector db. After the question is asked, it should give you an answer and then you can view the sources where it used.

![rag results](./images/rag_results.png "rag results")

As you can see above, the answer that the LLM gives is more specific to creating a Data Connection in RHOAI because it's uses the rhoai documents that are in the vector db.
