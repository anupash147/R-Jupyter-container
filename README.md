# R-Jupyter-container
This repository contains the basic code to start a R or Jupyter container. This project also has gdal support baked in.

To use the project you need to have some pre-requisit like docker, you should build the container and follow some simple instructions.

##Pre-requisits
    - Docker
    - Unix shell
    
## Building the container.
1. Clone the project.
    
    ```
    $ git clone https://github.com/anupash147/R-Jupyter-container.git
    ```
    
   *if you are looking for a specific tag. _FYI .. Tags are nothing but releases_
    
    ```$ git fetch && git fetch --tags
       $ git checkout  <tag> [-b <new branch for the tag>]
    ```
    
2. Provide the access credentials.
    
    ```
    $ cd R-Jupyter-container
    $ cp config.conf.template config.conf
    $ vi config.conf
    ```   
3. Source the command line utility. This file has short hand bash commands.

    ```
    $ source dev.sh
    ```
4. Build the container by simply running 
    ```
    $ build
    ```
   
   This will chain out a list of docker task in background. After the build is done you can validate your image by typing 
   ```
   $ docker images | grep rjupyter-container
   ```
5. To start a notebook as in-container development issue the following command.
    ```
    $ notebook
    ```

6. To do an in-container local R-studio development issue the following command.
    ```
    $ rstudio
    ```
    This will launch an rstudio session within a docker container and bind it to run on localport 8787.
    Run the command and test it by clicking on http://localhost:8787
       
     
                  
## Release Notes

| Release / Tag            |     Notes                                              |
|--------------------------|--------------------------------------------------------|
| 1.0.0                    | Initial version                                        |

    