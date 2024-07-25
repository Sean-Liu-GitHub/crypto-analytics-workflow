# <img width="50" alt="image" src="https://hackmd.io/_uploads/SyhRFVkYC.png"> GCP Data Engineering Project - Crypto Currencies Analysis part1: Data Ingestion with Cloud Composer built on Apache Airflow

When it comes to deploying Apache Airflow, docker container with a local or virtual machine is a common solution. However, if you are working with Google Cloud Platform (GCP), there is a fully managed workflow orchestration service called Cloud Composer. It is built on Apache Airflow so you can work on it just like write a python script to create a DAG.

## **Benefits using** [**Cloud Composer**](https://cloud.google.com/composer)

#### Fully managed workflow orchestration
Cloud Composer's managed nature and Apache Airflow compatibility allows you to focus on authoring, scheduling, and monitoring your workflows as opposed to provisioning resources.

#### Integrates with other Google Cloud products
End-to-end integration with Google Cloud products including BigQuery, Dataflow, Dataproc, Datastore, Cloud Storage, Pub/Sub, and AI Platform gives users the freedom to fully orchestrate their pipeline.

#### Supports hybrid and multi-cloud
Author, schedule, and monitor your workflows through a single orchestration tool—whether your pipeline lives on-premises, in multiple clouds, or fully within Google Cloud.

## Data source
[CoinCap API](https://docs.coincap.io/) is a useful tool for real-time pricing and market activity for over 1,000 cryptocurrencies. By collecting exchange data from thousands of markets, it offers transparent and accurate data on asset price and availability.

## Tech Stack
* Cloud - Google Cloud Platform (GCP)
* Infrastructure as Code (Iac) - Terraform
* Workflow Orchestration - Apache Airflow
* Workflow Managed Service - Cloud Composer
* Data Lake - Google Cloud Storage
* Data Warehouse - Big Query
* Programming Language - Python

## Workflow architecture
![crypto analytics workflow](https://hackmd.io/_uploads/ByM4EUJtA.png)

### Infrasture as Code
Terraform is used to set up GCP resources. In this project, I used it to set up cloud storage bucket and BigQuery datasets and enabled apis. Please see the terraform settings in this [folder](https://github.com/Sean-Liu-GitHub/crypto-analytics-workflow/tree/main/terraform).

### CoinCap API
One of the api endpoints is the asset api. 
#### URL
```
api.coincap.io/v2/assets
```
#### JSON Response
```
{
  "data": [
    {
      "id": "bitcoin",
      "rank": "1",
      "symbol": "BTC",
      "name": "Bitcoin",
      "supply": "17193925.0000000000000000",
      "maxSupply": "21000000.0000000000000000",
      "marketCapUsd": "119150835874.4699281625807300",
      "volumeUsd24Hr": "2927959461.1750323310959460",
      "priceUsd": "6929.8217756835584756",
      "changePercent24Hr": "-0.8101417214350335",
      "vwap24Hr": "7175.0663247679233209"
    },
    {
      "id": "ethereum",
      "rank": "2",
      "symbol": "ETH",
      "name": "Ethereum",
      "supply": "101160540.0000000000000000",
      "maxSupply": null,
      "marketCapUsd": "40967739219.6612727047843840",
      "volumeUsd24Hr": "1026669440.6451482672850841",
      "priceUsd": "404.9774667045200896",
      "changePercent24Hr": "-0.0999626159535347",
      "vwap24Hr": "415.3288028454417241"
    },
    ...
  ],
  "timestamp": 1533581088278
}
```
### Data Ingestion DAG in Cloud Composer
#### Prerequisite
Before uploading the DAG to cloud composer, I followed this official [quickstart doc](https://cloud.google.com/composer/docs/composer-2/run-apache-airflow-dag) to create an environment.

#### The DAG
All the tasks are in one DAG as this python script. https://github.com/Sean-Liu-GitHub/crypto-analytics-workflow/blob/main/airflow/dags/ingest_data.py
* Load api data to storage bucket
This process is divided into 3 tasks:
    1. Load data to the airflow server.
    2. Format the data to parquet in order to save storage space and process time.
    3. Upload parquet files to storage bucket.

* Data from storage bucket to BigQuery
In order to transform the data later with dbt, I loaded the data from GCS to BigQuery by using [Google Cloud Storage Transfer Operator to BigQuery](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/operators/transfer/gcs_to_bigquery.html).

## Details about Cloud Composer
#### Environment
We can check the location, airflow version and access to airflow webserver, DAGs, Logs and DAGs folder here.
![image](https://hackmd.io/_uploads/r1Gv6O1tC.png)
#### Monitor
We can check health of the environment here.
![image](https://hackmd.io/_uploads/H1sf0u1Y0.png)
#### DAGs
We can see all the DAGs in this tab.
![image](https://hackmd.io/_uploads/By3uRdJKR.png)
Please note that the .py files of these DAGs are stored in a storage bucket which was created during the cloud composer environment setup process. As you can see the following screenshot of the related bucket, the DAGs are the same with in cloud composer.
![image](https://hackmd.io/_uploads/SJycktyFA.png)
#### Create a new DAG
The way how we can create a new DAG is just to upload a new .py file to the bucket and cloud composer will be synced with the bucket in few minutes after the file upload completed. 
However, this is not a good practice if this is a production environment because we don't have versioning, testing and CI/CD.
Google has provided a way to create a CI/CD pipeline to test, synchronize, and deploy DAGs to your Cloud Composer environment from your GitHub repository in this [doc](https://cloud.google.com/composer/docs/composer-2/dag-cicd-github).
I will give it a go later to check if it is a good practice or not.

#### Airflow web server
Cloud composer provides the web server for user to manage airflow instance.
![image](https://hackmd.io/_uploads/SJAKGFJFR.png)

#### Environment variables
We can define the environment variables and use it in any DAGs.
![image](https://hackmd.io/_uploads/Hk-D7KyYC.png)

In the DAG, we can get the values like this
```
# environmental variables
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET_NAME = os.environ.get("GCP_GCS_BUCKET")
```
There are many features we can use in cloud composer. Please see the official [docs](https://cloud.google.com/composer/docs/composer-2/composer-overview) for further information.

## Next: Transform the data with dbt and create a report on Looker Studio
This repository includes the data ingestion part in this project. The data transformation part is in another repository which connects to dbt cloud.
I describe how I use dbt in this [repository](https://github.com/Sean-Liu-GitHub/coins-analytics-dbt).
