IMPORTANT ❗ ❗ ❗ Please remember to destroy all the resources after each work session. You can recreate infrastructure by creating new PR and merging it to master.
  
![img.png](doc/figures/destroy.png)

## 1. Authors

### 1.1. Team

- Łukasz Staniszewski
- Mateusz Szczepanowski
- Albert Ściseł

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

***place your diagram here***

## 9. Add costs by entering the expected consumption into Infracost

***place the expected consumption you entered here***

***place the screenshot from infracost output here***

## 10. Some resources are not supported by infracost yet. Estimate manually total costs of infrastructure based on pricing costs for region used in the project. Include costs of cloud composer, dataproc and AI vertex workbanch and them to infracost estimation

***place your estimation and references here***

***what are the options for cost optimization?***

## 11. Create a BigQuery dataset and an external table

***place the code and output here***

***why does ORC not require a table schema?***
  
## 12. Start an interactive session from Vertex AI workbench (steps 7-9 in README)

***place the screenshot of notebook here***

## 13. Find and correct the error in spark-job.py

***describe the cause and how to find the error***

## 14. Additional tasks using Terraform

1. Add support for arbitrary machine types and worker nodes for a Dataproc cluster and JupyterLab instance

***place the link to the modified file and inserted terraform code***

3. Add support for preemptible/spot instances in a Dataproc cluster

***place the link to the modified file and inserted terraform code***

3. Perform additional hardening of Jupyterlab environment, i.e. disable sudo access and enable secure boot

***place the link to the modified file and inserted terraform code***

4. (Optional) Get access to Apache Spark WebUI

***place the link to the modified file and inserted terraform code***
