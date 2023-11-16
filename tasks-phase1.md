IMPORTANT ❗ ❗ ❗ Please remember to destroy all the resources after each work session. You can recreate infrastructure by creating new PR and merging it to master.
  
![img.png](doc/figures/destroy.png)

## 1. Authors

### 1.1. Team

- Łukasz Staniszewski
- Albert Ściseł
- Mateusz Szczepanowski

### 1.2. Info

- Group number: 5
- Forked repo link: <https://github.com/thai-chicken/tbd-2023z-phase1>

## 2. Fork <https://github.com/bdg-tbd/tbd-2023z-phase1> and follow all steps in README.md

## 3. Select your project and set budget alerts on 5%, 25%, 50%, 80% of 50$ (in cloud console -> billing -> budget & alerts -> create buget; unclick discounts and promotions&others while creating budget)

  Screen:
  
  ![img.png](doc/figures/task3.png)

## 4. From avaialble Github Actions select and run destroy on main branch

  Screen:
  
  ![img.png](doc/figures/task4.png)

## 5. Create new git branch and add two resources in ```/modules/data-pipeline/main.tf```

- resource "google_storage_bucket" "tbd-data-bucket" -> the bucket to store data. Set the following properties:
  - project  // look for variable in variables.tf
  - name  // look for variable in variables.tf
  - location // look for variable in variables.tf
  - uniform_bucket_level_access = false #tfsec:ignore:google-storage-enable-ubla
     force_destroy               = true
  - public_access_prevention    = "enforced"
  - if checkcov returns error, add other properties if needed

- resource "google_storage_bucket_iam_member" "tbd-data-bucket-iam-editor" -> assign role storage.objectUser to data service account. Set the following properties:
  - bucket // refere to bucket name from tbd-data-bucket
  - role   // follow the instruction above
  - member = "serviceAccount:${var.data_service_account}"

#### Link to the modified file: <https://github.com/thai-chicken/tbd-2023z-phase1/blob/master/modules/data-pipeline/main.tf>

#### Snippet

```python

resource "google_storage_bucket" "tbd-data-bucket" {
    project                     = var.project_name
    name                        = var.data_bucket_name
    location                    = var.region
    uniform_bucket_level_access = false #tfsec:ignore:google-storage-enable-ubla
    force_destroy               = true
    public_access_prevention    = "enforced"

    #checkov:skip=CKV_GCP_29: "Ensure that Cloud Storage buckets have uniform bucket-level access enabled"
    #checkov:skip=CKV_GCP_62: "Bucket should log access"
    #checkov:skip=CKV_GCP_78: "Ensure Cloud storage has versioning enabled"
}

resource "google_storage_bucket_iam_member" "tbd-data-bucket-iam-editor" {
    bucket = google_storage_bucket.tbd-data-bucket.name
    role   = "roles/storage.objectUser"
    member = "serviceAccount:${var.data_service_account}"
}
```

- Create PR from this branch to **YOUR** master and merge it to make new release, place the screenshot from GA after succesfull application of release with this changes.

#### Screenshot of the release

![img.png](doc/figures/task5.png)

## 6. Analyze terraform code. Play with terraform plan, terraform graph to investigate different modules

- describe one selected module and put the output of terraform graph for this module here

#### Chosen module: ```/modules/data-pipeline```

The Terraform module **/modules/data-pipeline/main.tf** presented here defines resources for managing Google Cloud Storage (GCS) buckets and objects within those buckets.

##### Locals Block

The locals block is used to define local variables for reuse throughout the module, which makes the configuration more maintainable and readable.

##### Google Storage Bucket

The google_storage_bucket named tbd-code-bucket defines a GCS bucket. The bucket has public_access_prevention set to enforced, which prevents public access to the bucket.

##### Google Storage Bucket IAM Member Resource

The google_storage_bucket_iam_member resource named tbd-code-bucket-iam-viewer assigns the roles/storage.objectViewer role to a service account specified by var.data_service_account for the bucket defined earlier. This IAM role allows the service account to view objects in the bucket.

##### Google Storage Bucket Object Resources

There are two google_storage_bucket_object resources defined, job-code and dag-code. Each resource is responsible for creating objects (files) within the GCS buckets.

#### Fragment of plan command output

This command creates an execution plan - it determines what actions are necessary to accomplish the set goal defined in the Terraform files. Can help prevent unwanted changes (what to add, what to change and what to destroy).

```bash
~/.../tbd-2023z-phase1/modules/data-pipeline$ terraform plan

var.bucket_name
  Bucket for storing data pipeline additional code
  Enter a value: code_bucket

var.dag_bucket_name
  Apache Airflow bucket for storing DAGs
  Enter a value: dag_bucket

var.data_bucket_name
  Apache Airflow bucket for storing and processing data
  Enter a value: data_bucket

var.data_service_account
  Service account with READER role to the bucket storing code
  Enter a value: read_code_bucket

var.project_name
  Project name
  Enter a value: tbd_plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  ...

  + resource "google_storage_bucket_object" "job-code" {
      + bucket         = "code_bucket"
      + content        = (sensitive value)
      + content_type   = (known after apply)
      + crc32c         = (known after apply)
      + detect_md5hash = "different hash"
      + id             = (known after apply)
      + kms_key_name   = (known after apply)
      + md5hash        = (known after apply)
      + media_link     = (known after apply)
      + name           = "spark-job.py"
      + output_name    = (known after apply)
      + self_link      = (known after apply)
      + source         = "./resources/spark-job.py"
      + storage_class  = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.
```

#### Screenshot of terraform graph output

This command generates visual representations of an execution plan. Edges on the graph show dependencies between resources. The graph is in DOT format and can be rendered with tools such as Graphviz.

![img.png](doc/figures/task6graph.png)

## 7. Reach YARN UI

- place the port and the screenshot of YARN UI here

SSH tunnel is created using local port 1080 and in Chrome we can connect through the proxy with port **8088** using link:

<http://tbd-cluster-m:8088/cluster>

![img.png](doc/figures/task7.png)

## 8. Draw an architecture diagram (e.g. in draw.io) that includes

- VPC topology with service assignment to subnets
- Description of the components of service accounts
- List of buckets for disposal
- Description of network communication (ports, why it is necessary to specify the host for the driver) of Apache Spark running from Vertex AI Workbech
![img.png](doc/figures/TBD_task_8_diagram.png)

## 9. Add costs by entering the expected consumption into Infracost

We used `infracost-usage.yml` file to define the expected consumption. The file is located in the root directory of the project. Content (note: the values are only for example purposes):

```yaml
version: 0.1

resource_usage:
  #  The following usage values apply to individual resources and override any value defined in the resource_type_default_usage section.
  # All values are commented-out, you can uncomment resources and customize as needed.
  #
  module.vpc.module.cloud-router.google_compute_router_nat.nats["nat-gateway"]:
    assigned_vms: 1 # Number of VM instances assigned to the NAT gateway
    monthly_data_processed_gb: 2.0 # Monthly data processed (ingress and egress) by the NAT gateway in GB
  module.data-pipelines.google_storage_bucket.tbd-code-bucket:
    storage_gb: 3.0 # Total size of bucket in GB.
    monthly_class_a_operations: 5 # Monthly number of class A operations (object adds, bucket/object list).
    monthly_class_b_operations: 10 # Monthly number of class B operations (object gets, retrieve bucket/object metadata).
    monthly_data_retrieval_gb: 10.0 # Monthly amount of data retrieved in GB.
    monthly_egress_data_transfer_gb:
      same_continent: 4.0 # Same continent.
      worldwide: 5.0 # Worldwide excluding Asia, Australia.
      asia: 3.0 # Asia excluding China, but including Hong Kong.
      china: 2.0 # China excluding Hong Kong.
      australia: 0.0 # Australia.
  module.data-pipelines.google_storage_bucket.tbd-data-bucket:
    storage_gb: 3.0 # Total size of bucket in GB.
    monthly_class_a_operations: 5 # Monthly number of class A operations (object adds, bucket/object list).
    monthly_class_b_operations: 10 # Monthly number of class B operations (object gets, retrieve bucket/object metadata).
    monthly_data_retrieval_gb: 10.0 # Monthly amount of data retrieved in GB.
    monthly_egress_data_transfer_gb:
      same_continent: 4.0 # Same continent.
      worldwide: 5.0 # Worldwide excluding Asia, Australia.
      asia: 3.0 # Asia excluding China, but including Hong Kong.
      china: 2.0 # China excluding Hong Kong.
      australia: 0.0 # Australia.
  module.gcr.google_container_registry.registry:
    storage_gb: 3.0 # Total size of bucket in GB.
    monthly_class_a_operations: 5 # Monthly number of class A operations (object adds, bucket/object list).
    monthly_class_b_operations: 10 # Monthly number of class B operations (object gets, retrieve bucket/object metadata).
    monthly_data_retrieval_gb: 10.0 # Monthly amount of data retrieved in GB.
    monthly_egress_data_transfer_gb:
      same_continent: 4.0 # Same continent.
      worldwide: 5.0 # Worldwide excluding Asia, Australia.
      asia: 3.0 # Asia excluding China, but including Hong Kong.
      china: 2.0 # China excluding Hong Kong.
      australia: 0.0 # Australia.
  module.vertex_ai_workbench.google_storage_bucket.notebook-conf-bucket:
    storage_gb: 10.0 # Total size of bucket in GB.
    monthly_class_a_operations: 100 # Monthly number of class A operations (object adds, bucket/object list).
    monthly_class_b_operations: 150 # Monthly number of class B operations (object gets, retrieve bucket/object metadata).
    monthly_data_retrieval_gb: 8.0 # Monthly amount of data retrieved in GB.
    monthly_egress_data_transfer_gb:
      same_continent: 4.0 # Same continent.
      worldwide: 5.0 # Worldwide excluding Asia, Australia.
      asia: 3.0 # Asia excluding China, but including Hong Kong.
      china: 2.0 # China excluding Hong Kong.
      australia: 0.0 # Australia.
```

Infracost output assuming usage above:

```
> infracost breakdown --path . --usage-file infracost-usage.yml

Evaluating Terraform directory at .
  ✔ Downloading Terraform modules
  ✔ Evaluating Terraform directory
Warning: Input values were not provided for following Terraform variables: "variable.project_name", "variable.ai_notebook_instance_owner". Use --terraform-var-file or --terraform-var to
 specify them.
  ✔ Retrieving cloud prices to calculate costs

Project: thai-chicken/tbd-2023z-phase1

 Name                                                                                Monthly Qty  Unit             Monthly Cost

 module.data-pipelines.google_storage_bucket.tbd-code-bucket
 ├─ Storage (standard)                                                                         3  GiB                     $0.06
 ├─ Object adds, bucket/object list (class A)                                             0.0005  10k operations          $0.00
 ├─ Object gets, retrieve bucket/object metadata (class B)                                 0.001  10k operations          $0.00
 └─ Network egress
    ├─ Data transfer in same continent                                                         4  GB                      $0.08
    ├─ Data transfer to worldwide excluding Asia, Australia (first 1TB)                        5  GB                      $0.60
    ├─ Data transfer to Asia excluding China, but including Hong Kong (first 1TB)              3  GB                      $0.36
    ├─ Data transfer to China excluding Hong Kong (first 1TB)                                  2  GB                      $0.46
    └─ Data transfer to Australia (first 1TB)                                      Monthly cost depends on usage: $0.19 per GB

 module.data-pipelines.google_storage_bucket.tbd-data-bucket
 ├─ Storage (standard)                                                                         3  GiB                     $0.06
 ├─ Object adds, bucket/object list (class A)                                             0.0005  10k operations          $0.00
 ├─ Object gets, retrieve bucket/object metadata (class B)                                 0.001  10k operations          $0.00
 └─ Network egress
    ├─ Data transfer in same continent                                                         4  GB                      $0.08
    ├─ Data transfer to worldwide excluding Asia, Australia (first 1TB)                        5  GB                      $0.60
    ├─ Data transfer to Asia excluding China, but including Hong Kong (first 1TB)              3  GB                      $0.36
    ├─ Data transfer to China excluding Hong Kong (first 1TB)                                  2  GB                      $0.46
    └─ Data transfer to Australia (first 1TB)                                      Monthly cost depends on usage: $0.19 per GB

 module.gcr.google_container_registry.registry
 ├─ Storage (standard)                                                                         3  GiB                     $0.08
 ├─ Object adds, bucket/object list (class A)                                             0.0005  10k operations          $0.00
 ├─ Object gets, retrieve bucket/object metadata (class B)                                 0.001  10k operations          $0.00
 └─ Network egress
    ├─ Data transfer in same continent                                                         4  GB                      $0.08
    ├─ Data transfer to worldwide excluding Asia, Australia (first 1TB)                        5  GB                      $0.60
    ├─ Data transfer to Asia excluding China, but including Hong Kong (first 1TB)              3  GB                      $0.36
    ├─ Data transfer to China excluding Hong Kong (first 1TB)                                  2  GB                      $0.46
    └─ Data transfer to Australia (first 1TB)                                      Monthly cost depends on usage: $0.19 per GB

 module.vertex_ai_workbench.google_storage_bucket.notebook-conf-bucket
 ├─ Storage (standard)                                                                        10  GiB                     $0.20
 ├─ Object adds, bucket/object list (class A)                                               0.01  10k operations          $0.00
 ├─ Object gets, retrieve bucket/object metadata (class B)                                 0.015  10k operations          $0.00
 └─ Network egress
    ├─ Data transfer in same continent                                                         4  GB                      $0.08
    ├─ Data transfer to worldwide excluding Asia, Australia (first 1TB)                        5  GB                      $0.60
    ├─ Data transfer to Asia excluding China, but including Hong Kong (first 1TB)              3  GB                      $0.36
    ├─ Data transfer to China excluding Hong Kong (first 1TB)                                  2  GB                      $0.46
    └─ Data transfer to Australia (first 1TB)                                      Monthly cost depends on usage: $0.19 per GB

 module.vpc.module.cloud-router.google_compute_router_nat.nats["nat-gateway"]
 ├─ Assigned VMs (first 32)                                                                  730  VM-hours                $1.02
 └─ Data processed                                                                             2  GB                      $0.09

 OVERALL TOTAL                                                                                                            $7.51
──────────────────────────────────
31 cloud resources were detected:
∙ 5 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 23 were free, rerun with --show-skipped to see details
∙ 3 are not supported yet, rerun with --show-skipped to see details

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Project                                            ┃ Monthly cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ thai-chicken/tbd-2023z-phase1                      ┃ $8           ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```

## 10. Some resources are not supported by infracost yet. Estimate manually total costs of infrastructure based on pricing costs for region used in the project. Include costs of cloud composer, dataproc and AI vertex workbanch and them to infracost estimation

Resources not supported by infracost yet:
- 1 x google_composer_environment - Cloud Composer
- 1 x google_dataproc_cluster - Dataproc
- 1 x google_notebooks_instance - Vertex AI Workbench

***place your estimation and references here***

***what are the options for cost optimization?***

## 11. Create a BigQuery dataset and an external table

***place the code and output here***

```bash
> bq mk tbd_dataset

Welcome to BigQuery! This script will walk you through the
process of initializing your .bigqueryrc configuration file.

First, we need to set up your credentials if they do not
already exist.

Setting project_id tbd-2023z as the default.

BigQuery configuration complete! Type "bq" to get started.

Dataset 'tbd-2023z:tbd_dataset' successfully created.
> bq mk --table --external_table_definition=@ORC=gs://cloud-samples-data/bigquery/us-states/us-states.orc tbd_dataset.tbd_table
Table 'tbd-2023z:tbd_dataset.tbd_table' successfully created.
```

***why does ORC not require a table schema?***
Since ORC files add table schema in the file footer, it's unnecessary to specify the schema while creating a table in BigQuery since BigQuery can directly read the schema from the ORC file.

The metadata in an ORC file includes information such as (i.a.):

- The number of rows in the file
- Column schema
- File-level statistics
This essentially allows BigQuery to derive the needed table schema directly from the ORC file, eliminating the need to separately define it.

## 12. Start an interactive session from Vertex AI workbench (steps 7-9 in README)

***place the screenshot of notebook here***

![img.png](doc/figures/task12.png)

## 13. Find and correct the error in spark-job.py

***describe the cause and how to find the error***

- Cause: the reason why the spark job did not work was the given name of the bucket in which the data processed by the job should be stored. The solution was to change this name to the name of our bucket in one of the lines in the code of the spark-job.py file.

- How to find: in the dataproc jobs logs, where we found out that out spark job fails, we looked into the error message and there was such a log fragment:

```bash
{
  "code" : 404,
  "errors" : [ {
    "domain" : "global",
    "message" : "The specified bucket does not exist.",
    "reason" : "notFound"
  } ],
  "message" : "The specified bucket does not exist."
}
```

Corrected code in `spark-job.py`:

```

# change to your data bucket
DATA_BUCKET = "gs://tbd-2023z-304098-data/data/shakespeare/"

```

After that, the job passed successfully in the dataproc jobs logs:

![img.png](doc/figures/task13.png)

Also, here are the logs from the sumbition of the job:

```bash
mszczepanowski@C15581 tbd-2023z-phase1 % gcloud dataproc jobs submit pyspark modules/data-pipeline/resources/spark-job.py --cluster=tbd-cluster --region=europe-west1
Job [05fab19412154cfd84ec9a5d666c5302] submitted.

...

The top words in shakespeare are
+----+--------------+
|word|sum_word_count|
+----+--------------+
| the|         25568|
|   I|         21028|
| and|         19649|
|  to|         17361|
|  of|         16438|
|   a|         13409|
| you|         12527|
|  my|         11291|
|  in|         10589|
|  is|          8735|
|that|          8561|
| not|          8395|
|  me|          8030|
| And|          7780|
|with|          7224|
|  it|          7137|
| his|          6811|
|  be|          6724|
|your|          6244|
| for|          6154|
+----+--------------+
only showing top 20 rows

...

jobUuid: b077d36a-fb62-3972-883a-e0182b98541f
placement:
  clusterName: tbd-cluster
  clusterUuid: 328d2fb5-dafb-401b-af06-f7250ab9b3f5
pysparkJob:
  mainPythonFileUri: gs://dataproc-staging-europe-west1-519557031031-7e61v90i/google-cloud-dataproc-metainfo/328d2fb5-dafb-401b-af06-f7250ab9b3f5/jobs/05fab19412154cfd84ec9a5d666c5302/staging/spark-job.py
reference:
  jobId: 05fab19412154cfd84ec9a5d666c5302
  projectId: tbd-2023z-304098
status:
  state: DONE
  stateStartTime: '2023-11-16T20:32:09.528879Z'
statusHistory:
- state: PENDING
  stateStartTime: '2023-11-16T20:30:05.012613Z'
- state: SETUP_DONE
  stateStartTime: '2023-11-16T20:30:05.053908Z'
- details: Agent reported job success
  state: RUNNING
  stateStartTime: '2023-11-16T20:30:05.294453Z'
yarnApplications:
- name: Shakespeare WordCount
  progress: 1.0
  state: FINISHED
  trackingUrl: http://tbd-cluster-m.c.tbd-2023z-304098.internal.:8088/proxy/application_1700160019211_0005/
```

## 14. Additional tasks using Terraform

1. Add support for arbitrary machine types and worker nodes for a Dataproc cluster and JupyterLab instance

***place the link to the modified file and inserted terraform code***

We had to change `main.tf`, and `variable.tf` files in the root directory, in the `dataproc` module and in the `vertex-ai-workbench` module.

- In the `dataproc` module we added a new variable `num_workers` in the [`dataproc/variables.tf`](modules/dataproc/variables.tf), which represents number of worker nodes and is set default to 2:

  ```tf
  variable "num_workers" {
    type        = number
    default     = 2
    description = "Number of worker nodes"
  }
  ```

  Also, we had to include this variable in the [`dataproc/main.tf`](modules/dataproc/main.tf) file, in the `worker_config` block:

  ```tf
  worker_config {
    num_instances = var.num_workers
    machine_type  = var.machine_type
    disk_config {
      boot_disk_type    = "pd-standard"
      boot_disk_size_gb = 100
    }
  }
  ```

- In the `vertex-ai-workbench` module we added a new variable `machine_type` in the [`vertex-ai-workbench/variables.tf`](modules/vertex-ai-workbench/variables.tf), which represents machine type for notebook instance and is set default to "e2-standard-2":

  ```tf
  variable "machine_type" {
    type        = string
    default     = "e2-standard-2"
    description = "Machine type for notebook instance"
  }
  ```

  Also, in the [`vertex-ai-workbench/main.tf`](modules/vertex-ai-workbench/main.tf) file, we had to include this variable:

  ```tf
  resource "google_notebooks_instance" "tbd_notebook" {
    #checkov:skip=CKV2_GCP_18: "Ensure GCP network defines a firewall and does not use the default firewall"
    depends_on   = [google_project_service.notebooks]
    location     = local.zone
    machine_type = var.machine_type
    name         = "${var.project_name}-notebook"
    ...
  }
  ```

- Finally, in the root directory, we added 3 new variables in the [`variables.tf`](variables.tf) file:

  ```tf
  variable "dataproc_num_workers" {
    type        = number
    default     = 2
    description = "Number of dataproc workers"
  }

  variable "dataproc_worker_machine_type" {
    type        = string
    default     = "e2-standard-2"
    description = "Dataproc worker machine type"
  }

  variable "vertex_machine_type" {
    type        = string
    default     = "e2-standard-2"
    description = "Vertex AI machine type"
  }
  ```

  And, in the [`main.tf`](main.tf) file, we had to include these variables in the `dataproc` and `vertex-ai-workbench` modules:

  ```tf
  module "vertex_ai_workbench" {
    depends_on   = [module.jupyter_docker_image, module.vpc]
    source       = "./modules/vertex-ai-workbench"
    project_name = var.project_name
    region       = var.region
    network      = module.vpc.network.network_id
    subnet       = module.vpc.subnets[local.notebook_subnet_id].id
    machine_type = var.vertex_machine_type

    ai_notebook_instance_owner = var.ai_notebook_instance_owner
  }
  ...
  module "dataproc" {
    depends_on   = [module.vpc]
    source       = "./modules/dataproc"
    project_name = var.project_name
    region       = var.region
    subnet       = module.vpc.subnets[local.notebook_subnet_id].id
    machine_type = var.dataproc_worker_machine_type
    num_workers  = var.dataproc_num_workers
  }
  ```

2. Add support for preemptible/spot instances in a Dataproc cluster

***place the link to the modified file and inserted terraform code***

3. Perform additional hardening of Jupyterlab environment, i.e. disable sudo access and enable secure boot

***place the link to the modified file and inserted terraform code***

4. (Optional) Get access to Apache Spark WebUI

***place the link to the modified file and inserted terraform code***
