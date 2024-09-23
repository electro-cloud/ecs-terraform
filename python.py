import click
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# the clients
s3 = boto3.client('s3')
ecs = boto3.client('ecs')

# the bucket name used in the ECS project
BUCKET_NAME = 'nginx-logs-XXXXX'  
SERVICE_NAME = 'nginx-service'           
CLUSTER_NAME = 'ecs-cluster'              

@click.group()
def cli():
    """CLI for interacting with AWS resources."""
    pass

#  S3 bucket
@cli.command('list-s3-files')
def list_s3_files():
    """List files in the S3 bucket."""
    try:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)
        if 'Contents' in response:
            click.echo(f"Files in bucket '{BUCKET_NAME}':")
            for obj in response['Contents']:
                click.echo(f" - {obj['Key']}")
        else:
            click.echo(f"No files found in bucket '{BUCKET_NAME}'.")
    except NoCredentialsError:
        click.echo("AWS credentials not found.")
    except PartialCredentialsError:
        click.echo("Incomplete AWS credentials provided.")
    except Exception as e:
        click.echo(f"Error: {e}")

#  ECS task definition
@cli.command('list-ecs-task-def-versions')
def list_ecs_task_def_versions():
    """List the versions of the ECS task definition for the service."""
    try:
      
        response = ecs.describe_services(cluster=CLUSTER_NAME, services=[SERVICE_NAME])
        task_definition_arn = response['services'][0]['taskDefinition']
        task_definition_name = task_definition_arn.split('/')[1].split(':')[0]
        

        task_definitions = ecs.list_task_definitions(familyPrefix=task_definition_name)
        click.echo(f"Task definition versions for '{task_definition_name}':")
        for task_def in task_definitions['taskDefinitionArns']:
            click.echo(f" - {task_def}")
    except NoCredentialsError:
        click.echo("AWS credentials not found.")
    except PartialCredentialsError:
        click.echo("Incomplete AWS credentials provided.")
    except Exception as e:
        click.echo(f"Error: {e}")

if __name__ == "__main__":
    cli()

