



# importing necessary libraries 
import dropbox 
  
# Token Generated from dropbox 
TOKEN = "sl.u.AFjmFqQHbCkV6Fjow2H4i7AH9YiRY9Nk4Fn6lxsgTRknW_i1ch8b6N0sT14v8_u5FnYc-WBcn6wFISntyAIKut30WMukuRKHhHVfrqqyogxcC_MiNVWvzVYrAaQ7ECQDm1AOj_Db8dEvmHzz29EIv2tfJXR-7AdOzeyWPgrXnbl45T6YdajslwYM7oFIcYqIDblknNvlD6PDJc9cmiOiTpII_aUFeJcR2lQq71iAyr40jeeDuB6Iz2QzQdV9-y7mn5F43OVjDpVEvKh1n2yab_GHtErZtog-ayKDhyQiYozFRHCSUMlZQU3GOqfw2uZnAMoh7yAjg9RpSYncbYEsB1_397sP9jDOR37TwX6_YzXLi6iLdp-i3R_9dAneXiw2ZpuDHMTRtIleBZJrQPkQKV_Du7BBZuTvoFUDQv_tVWBuZ_nViBcFI1kGDQ_USWpwY8s03zWKRqtHj80CqK6N80igCGko494JyomeFK0Rf5pWAK9p1Erl89AoyzkY7qjQLroyAOGYa0lrkliEybqr3aaIHt7ifsx4GrCmUh56TiyzhM1Orwy37428OR88VsVh2qVxpEpWJvOUeCo9CCpgLM8Px4UpiDB9FgnYefNQSj1roHE4NilNVa9Lyr8qngsTawcFzlT8SpTx0EkpNQLINe3EWH8G1CLTE7CgYHolv_rqGIERgg4bG8tpQDV1qqhvTKpIhybZKwtjhtart7QVsT7V1s_67c0DPZholTx81j0fjS950anO5TyaSs-YTXylNqAq1TIWz0NO2TffJi_b32w0ph_aBDDKYtKm3tA4t--yceqF2vKzjU9v9LE8NYNuWsok1ga25DLPj1JZWXzKzU3ue1r1bBv81rg1oUQb8blwk614Mvwuwyp61rlzjbdZmDgVWCmaOGT3rMvLNPHKV1l9QJ1et4HwSwI4w2If5KK2uv4eh8Ab66pA88qQzCnesyhl9m-Rht7OumfP08dPCM4LJ-1ABnKFaEB6JFrf9X4qwiybhLL9drVraJG2shPrkxLI7m-fvRhEJWZDrH4qTGCZBfYoiiMA6RjiD8v3hhIe1U1c9zmxbdgM-NKJ0zTfe9hqZOK6g8xbE0VkVPdGDDLuRJ1Zsc0190vv-6fde4UwMtKu2EBKq9XYE4DEYagikHhXMYsciH5U37x8TsWzUxy7SrVZPg848YTU1aIuzIaCOIfbyLwNoh2gy9YYCvQ-4V8zgGZoGQDZDAPQg2qvigIcTGy3FbVTm1gQqz4n3nrXjBTtRSwgoWmsROEwOArRHHrMi5VDQtIfHo2fhE-rIOOm"
  
# Establish connection 
def connect_to_dropbox(): 
    
    try: 
        dbx = dropbox.Dropbox(TOKEN) 
        print('Connected to Dropbox successfully') 
      
    except Exception as e: 
        print(str(e)) 
      
    return dbx 
  
# explicit function to list files 
def list_files_in_folder(): 
    
    # here dbx is an object which is obtained 
    # by connecting to dropbox via token 
    dbx = connect_to_dropbox() 
      
    try: 
        folder_path = "/folder_path"
  
        # dbx object contains all functions that  
        # are required to perform actions with dropbox 
        files = dbx.files_list_folder(folder_path).entries 
        print("------------Listing Files in Folder------------ ") 
          
        for file in files: 
              
            # listing 
            print(file.name) 
              
    except Exception as e: 
        print(str(e)) 
  
class TransferData:
    def __init__(self, access_token):
        self.access_token = access_token

    def upload_file(self, file_from, file_to):
        """upload a file to Dropbox using API v2
        """
        dbx = dropbox.Dropbox(self.access_token)

        with open(file_from, 'rb') as f:
            dbx.files_upload(f.read(), file_to)

def main():
    access_token = '******'
    transferData = TransferData(access_token)

    file_from = 'test.txt'
    file_to = '/test_dropbox/test.txt'  # The full path to upload the file to, including the file name

    # API v2
    transferData.upload_file(file_from, file_to)

if __name__ == '__main__':
    main()
    
dbx = connect_to_dropbox() 
list_files_in_folder()