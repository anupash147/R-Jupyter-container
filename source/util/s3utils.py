from os import environ
from os import makedirs
from os.path import basename, splitext, dirname, exists

import boto3
from boto3.s3.transfer import S3Transfer
from botocore.exceptions import ClientError

LOCAL_DATA_LOC = '/vsr-models/data'


def get_environment(variable):
    try:
        return environ[variable]
    except:
        return None


def upload_to_s3(sourcefile, destination):
    AWS_ACCESS_KEY = get_environment('AWS_ACCESS_KEY_ID')
    AWS_SECRET_KEY = get_environment('AWS_SECRET_ACCESS_KEY')

    if AWS_ACCESS_KEY == None:
        client = boto3.client('s3')
    else:
        client = boto3.client('s3',
                              aws_access_key_id=AWS_ACCESS_KEY,
                              aws_secret_access_key=AWS_SECRET_KEY
                              )
    s3C = S3Transfer(client)
    _, path = destination.split(":", 1)
    path = path.lstrip("/")
    bucket, prefix = path.split("/", 1)
    print('s3://{}/{}'.format(bucket, prefix))
    try:
        s3C.upload_file(sourcefile, bucket, prefix,
                        extra_args={'ServerSideEncryption': "AES256"})
        # print('Folder uploaded successfully')
    except boto3.exceptions.S3UploadFailedError:
        print("Upload failed: Access denied")
        # sys.exit(1)
        return False


def locate_files(s3files, destFolder):
    if exists(destFolder + '/' + basename(s3files)):
        pass
    else:
        try:
            makedirs(destFolder)
        except:
            pass
        download_s3file(s3files, destFolder)


def download_s3file(filename, destlocation):
    if splitext(basename(filename))[1] == ".shp" or splitext(basename(filename))[1] == ".*":

        searchkey = splitext(basename(filename))[0]
    else:
        searchkey = basename(filename)
    destlocation = destlocation

    AWS_ACCESS_KEY = get_environment('AWS_ACCESS_KEY_ID')
    AWS_SECRET_KEY = get_environment('AWS_SECRET_ACCESS_KEY')

    if AWS_ACCESS_KEY == None:
        client = boto3.client('s3')
        resource = boto3.resource('s3')
    else:
        client = boto3.client('s3',
                              aws_access_key_id=AWS_ACCESS_KEY,
                              aws_secret_access_key=AWS_SECRET_KEY
                              )
        resource = boto3.resource('s3',
                                  aws_access_key_id=AWS_ACCESS_KEY,
                                  aws_secret_access_key=AWS_SECRET_KEY
                                  )

    filename = dirname(filename) + '/'
    _, path = filename.split(":", 1)
    path = path.lstrip("/")
    bucket, dist = path.split("/", 1)

    paginator = client.get_paginator('list_objects')
    try:
        for result in paginator.paginate(Bucket=bucket, Delimiter='/', Prefix=dist):
            if result.get('Contents') is not None:
                for file in result.get('Contents'):
                    if not exists(destlocation):
                        makedirs(destlocation)
                    # sometimes the first object is blank, ignore and process rest
                    if basename(file.get('Key')) != '':
                        # print(basename(file.get('Key')))
                        if basename(file.get('Key')).find(searchkey) == 0:
                            print('Downloading ...' + file.get('Key'))
                            resource.meta.client.download_file(bucket, file.get('Key'),
                                                               destlocation + '/' + basename(file.get('Key')))
        return True
    except ClientError:
        print('Access denied: Cannot download folder')
        return False


def required_files(s3file):
    """
    This function is designed to download files from s3 to data folder.
    :param s3file: s3 location of the file

    :returns : local location of the file.
    """
    if len(splitext(s3file)[1]) == 0:
        # downloading folder
        download_folder = '{}/{}'.format(LOCAL_DATA_LOC, basename(s3file.rstrip('/')))
        locate_files(s3file, download_folder)
        return download_folder
    else:
        # if the file to be downloaded then download in its own folder; especially because the names gets messy
        if splitext(basename(s3file))[1] == ".shp":
            shp_own_folder = LOCAL_DATA_LOC + '/' + basename(dirname(s3file))
            locate_files(s3file, shp_own_folder + '/')
            return '{}/{}'.format(shp_own_folder, basename(s3file))
        else:
            locate_files(s3file, LOCAL_DATA_LOC + '/')
            return '{}/{}'.format(LOCAL_DATA_LOC, basename(s3file))
