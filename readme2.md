### List clouddrive
Assuming you have previously connected to Cloud Shell before and already setup the Storage Account [more details here](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage) Next, you will need to connect to the Azure Files share in which CloudDrive is configured to use, so you can copy and paste the Terraform files in this repo. [To see which Azure Files share CloudDrive is using](https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage#list-clouddrive), run the `df` command.

```
justin@Azure:~$ df
Filesystem                                          1K-blocks   Used  Available Use% Mounted on
overlay                                             29711408 5577940   24117084  19% /
tmpfs                                                 986716       0     986716   0% /dev
tmpfs                                                 986716       0     986716   0% /sys/fs/cgroup
/dev/sda1                                           29711408 5577940   24117084  19% /etc/hosts
shm                                                    65536       0      65536   0% /dev/shm
//mystoragename.file.core.windows.net/fileshareName 5368709120    64 5368709056   1% /home/justin/clouddrive
justin@Azure:~$
```
In this instance, the storage account is **mystoragename** and the Azure Files Share is **fileshareName**.
### Mount SMB Azure file share
Next thing you need to do is mount the Azure Files Share on your local device, Windows, Linux, macOS - [https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows)

Once the Azure Files share is mounted, simply create a folder in the root of the drive and copy the files in this repo to it.